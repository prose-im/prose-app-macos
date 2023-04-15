//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppDomain
import BareMinimum
import Combine
import ComposableArchitecture
import Foundation
import OSLog
import ProseCoreFFI

struct NotConnectedError: Error {}

final class OSLogger: ProseCoreFFI.Logger {
  private let logger = os.Logger(subsystem: "org.prose.app", category: "ffi")

  func log(level: LogLevel, message: String) {
    switch level {
    case .trace:
      self.logger.trace("\(message)")
    case .debug:
      self.logger.debug("\(message)")
    case .info:
      self.logger.info("\(message)")
    case .warn:
      self.logger.warning("\(message)")
    case .error:
      self.logger.error("\(message)")
    }
  }
}

let loggerLock = UnfairLock()
var loggerInitialized = false

extension ProseCoreClient {
  static func live() -> Self {
    let connectionStatus = CurrentValueSubject<ConnectionStatus, Never>(.disconnected)
    let events = PassthroughSubject<ClientEvent, Never>()
    let actor = ClientActor()

    if ProcessInfo.processInfo.environment["PROSE_CORE_LOG_ENABLED"] == "1" {
      loggerLock.withLock {
        if !loggerInitialized {
          loggerInitialized = true

          let logLevel = {
            switch ProcessInfo.processInfo.environment["PROSE_CORE_LOG_LEVEL"]?.lowercased() {
            case "trace": return LogLevel.trace
            case "debug": return LogLevel.debug
            case "info": return LogLevel.info
            case "warn": return LogLevel.warn
            case "error": return LogLevel.error
            default: return LogLevel.warn
            }
          }()

          setLogger(logger: OSLogger(), maxLevel: logLevel)
        }
      }
    }

    func connectWithBackoff(
      credentials: Credentials,
      backoff: Duration = .seconds(3),
      numberOfRetries: Int = 3
    ) async throws {
      guard
        connectionStatus.value != .connected,
        connectionStatus.value != .connecting
      else {
        print("Ignoring connection attempt", credentials.jid)
        return
      }

      connectionStatus.value = .connecting

      do {
        let client = await actor.setupClient(
          jid: FullJid(
            node: credentials.jid.node,
            domain: credentials.jid.domain,
            resource: "macOS"
          ),
          delegate: ClientDelegate(connectionSubject: connectionStatus, eventsSubject: events)
        )
        try await client.connect(password: credentials.password)
        connectionStatus.value = .connected
        print("Connected", credentials.jid)
      } catch {
        print("Connection failed", credentials.jid)
        if numberOfRetries < 1 {
          connectionStatus.value = .disconnected
          throw error
        }

        try await Task.sleep(for: backoff)
        try await connectWithBackoff(
          credentials: credentials,
          backoff: backoff * 2,
          numberOfRetries: numberOfRetries - 1
        )
      }
    }

    func withClient<T>(_ block: (ProseCoreFFI.Client) async throws -> T) async throws -> T {
      guard let client = await actor.client else {
        throw NotConnectedError()
      }
      return try await block(client)
    }

    return .init(
      connectionStatus: {
        AsyncStream(connectionStatus.removeDuplicates().values)
      },
      events: {
        AsyncStream(events.values)
      },
      connect: { credentials, retry in
        try await connectWithBackoff(credentials: credentials, numberOfRetries: retry ? 3 : 0)
      },
      disconnect: {
        try await Task {
          try await actor.client?.disconnect()
        }.value
      },
      loadProfile: { jid in
        try await withClient { client in
          try await client.loadProfile(from: jid)
        }
      },
      loadContacts: {
        try await withClient { client in
          try await client.loadContacts()
        }
      },
      loadAvatar: { jid in
        try await withClient { client in
          try await client.loadAvatar(from: jid)
        }
      },
      sendMessage: { to, body in
        try await withClient { client in
          try await client.sendMessage(to: to, body: body)
        }
      },
      updateMessage: { conversation, messageId, body in
        try await withClient { client in
          try await client.updateMessage(conversation: conversation, id: messageId, body: body)
        }
      },
      toggleReactionToMessage: { conversation, messageId, emoji in
        try await withClient { client in
          try await client.toggleReactionToMessage(
            conversation: conversation,
            id: messageId,
            emoji: emoji
          )
        }
      },
      retractMessage: { conversation, messageId in
        try await withClient { client in
          try await client.retractMessage(conversation: conversation, id: messageId)
        }
      },
      sendChatState: { conversation, state in
        try await withClient { client in
          try await client.sendChatState(conversation: conversation, chatState: state)
        }
      },
      loadLatestMessages: { conversation, since, loadFromServer in
        try await withClient { client in
          try await client.loadLatestMessages(
            from: conversation,
            since: since,
            loadFromServer: loadFromServer
          )
        }
      },
      loadMessagesBefore: { conversation, before in
        try await withClient { client in
          try await client.loadMessagesBefore(from: conversation, before: before)
        }
      },
      loadMessagesWithIds: { conversation, ids in
        try await withClient { client in
          try await client.loadMessagesWithIds(conversation: conversation, ids: ids)
        }
      }
    )
  }
}

private actor ClientActor {
  var client: ProseCoreFFI.Client?

  func setupClient(jid: FullJid, delegate: ClientDelegate) -> ProseCoreFFI.Client {
    if let client = self.client {
      return client
    }

    do {
      let cacheDirectory = try FileManager.default.url(
        for: .cachesDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: false
      )
      .appendingPathComponent("ProseCoreCache")

      let client = try ProseCoreFFI.Client(
        jid: jid,
        cacheDir: cacheDirectory.path,
        delegate: delegate
      )
      self.client = client
      return client
    } catch {
      fatalError("Failed to initialize core client. \(error.localizedDescription)")
    }
  }
}

private final class ClientDelegate: ProseCoreFFI.ClientDelegate {
  let connectionSubject: CurrentValueSubject<ConnectionStatus, Never>
  let eventsSubject: PassthroughSubject<ClientEvent, Never>

  init(
    connectionSubject: CurrentValueSubject<ConnectionStatus, Never>,
    eventsSubject: PassthroughSubject<ClientEvent, Never>
  ) {
    self.connectionSubject = connectionSubject
    self.eventsSubject = eventsSubject
  }

  func handleEvent(event: ClientEvent) {
    switch event {
    case .connectionStatusChanged(.connect):
      self.connectionSubject.send(.connected)
    case let .connectionStatusChanged(.disconnect(error)):
      self.connectionSubject.send(.error(error))
    default:
      break
    }
    self.eventsSubject.send(event)
  }
}
