import AppDomain
import Combine
import ComposableArchitecture
import ProseCore

extension ProseCoreClient {
  static func live() -> Self {
    let connectionStatus = CurrentValueSubject<ConnectionStatus, Never>(.disconnected)
    var client: XmppClient?

    enableLogging()

    return .init(
      login: { credentials in
        client = .init(
          jid: FullJid(
            node: credentials.jid.node,
            domain: credentials.jid.domain,
            resource: "macOS"
          )
        )
        try client?.connect(
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
    )
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
