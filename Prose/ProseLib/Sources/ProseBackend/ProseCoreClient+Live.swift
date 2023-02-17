import AppDomain
import Combine
import ComposableArchitecture
import ProseCore

extension ProseCoreClient {
  static func live() -> Self {
    let connectionStatus = CurrentValueSubject<ConnectionStatus, Never>(.connecting)
    let actor = ClientActor()

    enableLogging()

    func connect(credentials: Credentials) async throws {
      try await actor.setupClient(jid: FullJid(
        node: credentials.jid.node,
        domain: credentials.jid.domain,
        resource: "macOS"
      )).connect(
        password: credentials.password,
        handler: ConnectionHandler(subject: connectionStatus)
      )

      for await status in connectionStatus.values {
        switch status {
        case .connected:
          return
        case let .error(error):
          throw error
        case .disconnected, .connecting:
          continue
        }
      }
    }

    func connectWithBackoff(
      credentials: Credentials,
      backoff: Duration = .seconds(3),
      numberOfRetries: Int = 3
    ) async throws {
      do {
        try await connect(credentials: credentials)
      } catch {
        if numberOfRetries < 1 {
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

    return .init(
      connectionStatus: {
        connectionStatus.eraseToAnyPublisher()
      },
      connect: { credentials, retry in
        if retry {
          try await connectWithBackoff(credentials: credentials)
        } else {
          try await connect(credentials: credentials)
        }
      },
      disconnect: {
        try await Task {
          try await actor.client?.disconnect()
        }.value
      }
    )
  }
}

actor ClientActor {
  var client: XmppClient?

  func setupClient(jid: FullJid) -> XmppClient {
    let client = XmppClient(jid: jid)
    self.client = client
    return client
  }
}

private final class ConnectionHandler: ProseCore.ConnectionHandler {
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
