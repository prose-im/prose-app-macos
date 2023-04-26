//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import BareMinimum
import Combine
import ComposableArchitecture
import Foundation

enum AccountError: Error {
  case unknownAccount
  case alreadyLoggedIn
}

extension AccountsClient {
  static func live(
    clientProvider: @escaping (BareJid) -> ProseCoreClient = ProseCoreClient.live
  ) -> Self {
    let accounts = CurrentValueSubject<[BareJid: ProseCoreClient], Never>([:])
    var ephemeralAccounts = [BareJid: ProseCoreClient]()
    let lock = UnfairLock()

    return .init(
      accounts: {
        AsyncStream(accounts.map { Set($0.keys) }.removeDuplicates().values)
      },
      addAccount: { jid in
        lock.synchronized {
          guard accounts.value[jid] == nil else {
            return
          }
          accounts.value[jid] = clientProvider(jid)
        }
      },
      removeAccount: { jid in
        guard let client = lock.synchronized(body: { accounts.value.removeValue(forKey: jid) })
        else { return }
        Task {
          try await client.disconnect()
        }
      },
      client: { jid in
        try lock.synchronized {
          guard let client = accounts.value[jid] else {
            throw AccountError.unknownAccount
          }
          return client
        }
      },
      addEphemeralAccount: { jid in
        try lock.synchronized {
          guard accounts.value[jid] == nil else {
            throw AccountError.alreadyLoggedIn
          }
          guard ephemeralAccounts[jid] == nil else {
            return
          }
          ephemeralAccounts[jid] = clientProvider(jid)
        }
      },
      removeEphemeralAccount: { jid in
        guard let client = lock.synchronized(body: { ephemeralAccounts.removeValue(forKey: jid) })
        else { return }
        Task {
          try await client.disconnect()
        }
      },
      promoteEphemeralAccount: { jid in
        try lock.synchronized {
          guard let client = ephemeralAccounts.removeValue(forKey: jid) else {
            return
          }
          guard accounts.value[jid] == nil else {
            throw AccountError.alreadyLoggedIn
          }
          accounts.value[jid] = client
        }
      },
      ephemeralClient: { jid in
        try lock.synchronized {
          guard let client = ephemeralAccounts[jid] else {
            throw AccountError.unknownAccount
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
