import AppDomain
import Combine
import ComposableArchitecture
import Foundation
import ProseCoreFFI

struct NotConnectedError: Error {}

extension ProseCoreClient {
  static func live() -> Self {
    let connectionStatus = CurrentValueSubject<ConnectionStatus, Never>(.disconnected)
    let actor = ClientActor()

    if ProcessInfo.processInfo.environment["PROSE_CORE_LOG_ENABLED"] == "1" {
      enableLogging()
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
      loadRoster: {
        try await withClient { client in
          try await client.loadRoster()
        }
      },
      loadAvatar: { jid in
        try await withClient { client in
          try await client.loadAvatar(from: jid)
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

      let client = try ProseCoreFFI.Client(jid: jid, cacheDir: cacheDirectory.path)
      client.setDelegate(delegate: delegate)
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

  func connectionStatusDidChange(event: ConnectionEvent) {
    switch event {
    case .connect:
      self.subject.send(.connected)
    case let .disconnect(error):
      self.subject.send(.error(error))
    }
  }
}
