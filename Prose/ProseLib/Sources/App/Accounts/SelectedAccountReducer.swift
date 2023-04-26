//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import ComposableArchitecture
import ProseCore

private extension AppReducer.State {
  var selectedAccount: Account? {
    self.selectedAccountId.flatMap {
      self.availableAccounts[id: $0]
    }
  }
}

// Observes changes to the selected account
struct SelectedAccountReducer<
  Base: ReducerProtocol<AppReducer.State, AppReducer.Action>
>: ReducerProtocol {
  let base: Base

  @Dependency(\.accountsClient) var accounts

  public var body: some ReducerProtocol<AppReducer.State, AppReducer.Action> {
    // Make sure that the selected account actually changed and not that the selection was replaced
    self.base
      .onChange(of: \.selectedAccount) { formerAccount, currentAccount, _, _ in
        guard
          let formerAccount,
          let currentAccount,
          formerAccount.jid == currentAccount.jid
        else {
          return .none
        }

        var effects = [EffectTask<Action>]()

        if currentAccount.availability != formerAccount.availability {
          effects.append(.fireAndForget {
            try await self.accounts.client(currentAccount.jid)
              .setAvailability(currentAccount.availability, nil)
          })
        }

        if currentAccount.settings != formerAccount.settings {
          effects.append(.fireAndForget {
            try await self.accounts.client(currentAccount.jid)
              .saveAccountSettings(currentAccount.settings)
          })
        }

        return .merge(effects)
      }
  }
}
