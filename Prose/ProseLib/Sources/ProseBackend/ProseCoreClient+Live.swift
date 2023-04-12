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
    let actor = ClientActor()

    if ProcessInfo.processInfo.environment["PROSE_CORE_LOG_ENABLED"] == "1" {
      loggerLock.withLock {
        if !loggerInitialized {
          loggerInitialized = true
          setLogger(logger: OSLogger(), maxLevel: .info)
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
          delegate: ClientDelegate(subject: connectionStatus)
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
  let subject: CurrentValueSubject<ConnectionStatus, Never>

  init(subject: CurrentValueSubject<ConnectionStatus, Never>) {
    self.subject = subject
  }

  func handleEvent(event: ClientEvent) {
    switch event {
    case .connectionStatusChanged(.connect):
      self.subject.send(.connected)
    case let .connectionStatusChanged(.disconnect(error)):
      self.subject.send(.error(error))
    default:
      break
    }
  }
}
