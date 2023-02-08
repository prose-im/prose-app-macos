import AppDomain
import Combine
import ComposableArchitecture
import Foundation

extension AccountsClient {
  static func live(clientProvider: @escaping () -> ProseCoreClient = ProseCoreClient.live) -> Self {
    let accounts = CurrentValueSubject<[BareJid: Account], Never>([:])

    return .init(
      availableAccounts: {
        AsyncStream(accounts.map { Array($0.values) }.values)
      },
      tryConnectAccount: { credentials in
        let client = clientProvider()
        try await client.login(credentials)
        accounts.value[credentials.jid] = .init(jid: credentials.jid, status: .connected)
      },
      connectAccounts: { credentials in
        for item in credentials {
          let client = clientProvider()
          Task {
            try await client.login(item)
          }
          accounts.value[item.jid] = .init(jid: item.jid, status: .connecting)
        }
      },
      disconnectAccount: { jid in
        accounts.value.removeValue(forKey: jid)
      }
    )
  }
}

extension AccountsClient: DependencyKey {
  public static var liveValue = AccountsClient.live()
}
