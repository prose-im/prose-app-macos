//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppDomain
import BareMinimum
import Combine
import ComposableArchitecture
import Foundation
import ProseCoreFFI

struct NoSuchAccountError: Error {}

extension AccountsClient {
  static func live(clientProvider: @escaping () -> ProseCoreClient = ProseCoreClient.live) -> Self {
    let accounts = CurrentValueSubject<[BareJid: ProseCoreClient], Never>([:])
    let lock = UnfairLock()

    func storeClient(client: ProseCoreClient, jid: BareJid) {
      lock.synchronized {
        accounts.value[jid] = client
      }
    }

    return .init(
      availableAccounts: {
        AsyncStream(accounts.map { Set($0.keys) }.removeDuplicates().values)
      },
      tryConnectAccount: { credentials in
        if accounts.value[credentials.jid] != nil {
          return
        }
        let client = clientProvider()
        try await client.connect(credentials, false)
        lock.synchronized {
          accounts.value[credentials.jid] = client
        }
      },
      connectAccounts: { credentials in
        for item in credentials {
          let client = clientProvider()
          lock.synchronized {
            accounts.value[item.jid] = client
          }
          Task {
            try await client.connect(item, true)
          }
        }
      },
      reconnectAccount: { credentials, retryAutomatically in
        guard let client = lock.synchronized(body: { accounts.value[credentials.jid] }) else {
          return
        }
        Task {
          try await client.connect(credentials, retryAutomatically)
        }
      },
      disconnectAccount: { jid in
        guard let client = lock.synchronized(body: { accounts.value.removeValue(forKey: jid) })
        else {
          return
        }
        try await client.disconnect()
      },
      client: { jid in
        try lock.synchronized {
          guard let client = accounts.value[jid] else {
            throw NoSuchAccountError()
          }
          return client
        }
      }
    )
  }
}

extension AccountsClient: DependencyKey {
  public static var liveValue = AccountsClient.live()
}
