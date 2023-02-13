import AppDomain
import Combine
import ComposableArchitecture
import Foundation

struct _Account {
  var jid: BareJid
  var client: ProseCoreClient

  var account: Account {
    .init(jid: self.jid, status: .connecting)
  }
}

extension AccountsClient {
  static func live(clientProvider: @escaping () -> ProseCoreClient = ProseCoreClient.live) -> Self {
    let accounts = CurrentValueSubject<[BareJid: _Account], Never>([:])

    return .init(
      availableAccounts: {
        AsyncStream(accounts.map { $0.values.map(\.account) }.values)
      },
      tryConnectAccount: { credentials in
        let client = clientProvider()
        try await client.connect(credentials)
        accounts.value[credentials.jid] = .init(jid: credentials.jid, client: client)
      },
      connectAccounts: { credentials in
        for item in credentials {
          let client = clientProvider()
          Task {
            try await client.connect(item)
          }
          accounts.value[item.jid] = .init(jid: item.jid, client: client)
        }
      },
      disconnectAccount: { jid in
        let account = accounts.value.removeValue(forKey: jid)
        try await account?.client.disconnect()
      }
    )
  }
}

extension AccountsClient: DependencyKey {
  public static var liveValue = AccountsClient.live()
}
