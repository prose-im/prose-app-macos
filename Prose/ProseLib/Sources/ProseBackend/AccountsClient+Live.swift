import AppDomain
import Combine
import ComposableArchitecture
import Foundation
import ProseCore

struct _Account {
  var jid: BareJid
  var client: ProseCoreClient
  var status: ConnectionStatus = .connecting
  var observation: AnyCancellable

  var account: Account {
    .init(jid: self.jid, status: self.status)
  }
}

#warning("Thread-safety!")

extension AccountsClient {
  static func live(clientProvider: @escaping () -> ProseCoreClient = ProseCoreClient.live) -> Self {
    let accounts = CurrentValueSubject<[BareJid: _Account], Never>([:])

    func storeClient(client: ProseCoreClient, jid: BareJid) {
      let observation = client.connectionStatus()
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { [weak accounts] status in
          accounts?.value[jid]?.status = status
        })

      accounts.value[jid] = .init(jid: jid, client: client, observation: observation)
    }

    func connect(client: ProseCoreClient, credentials: Credentials, withBackOff: Bool) {
      Task {
        accounts.value[credentials.jid]?.status = .connecting
        do {
          try await client.connect(credentials, withBackOff)
        } catch {
          accounts.value[credentials.jid]?.status = .disconnected
          return
        }
        accounts.value[credentials.jid]?.status = .connected
      }
    }

    return .init(
      availableAccounts: {
        AsyncStream(accounts.map { $0.mapValues(\.account) }.removeDuplicates().values)
      },
      tryConnectAccount: { credentials in
        if accounts.value[credentials.jid] != nil {
          return
        }
        let client = clientProvider()
        try await client.connect(credentials, false)
        storeClient(client: client, jid: credentials.jid)
      },
      connectAccounts: { credentials in
        for item in credentials {
          let client = clientProvider()
          storeClient(client: client, jid: item.jid)
          connect(client: client, credentials: item, withBackOff: true)
        }
      },
      reconnectAccount: { credentials, retryAutomatically in
        guard
          let account = accounts.value[credentials.jid],
          account.status != .connected,
          account.status != .connecting
        else {
          return
        }

        accounts.value[credentials.jid]?.status = .connecting
        connect(client: account.client, credentials: credentials, withBackOff: retryAutomatically)
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
