import AppDomain
import Combine
import ComposableArchitecture
import ProseCore

extension ProseCoreClient {
  static func live() -> Self {
    let connectionStatus = CurrentValueSubject<ConnectionStatus, Never>(.disconnected)
    let actor = ClientActor()

    enableLogging()

    return .init(
      connect: { credentials in
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
