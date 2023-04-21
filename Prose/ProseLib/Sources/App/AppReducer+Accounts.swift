//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import BareMinimum
import ComposableArchitecture
import CredentialsClient
import Foundation
import ProseCore

extension ReducerProtocol<AppReducer.State, AppReducer.Action> {
  @ReducerBuilder<AppReducer.State, AppReducer.Action>
  func handleAccounts() -> some ReducerProtocol<AppReducer.State, AppReducer.Action> {
    SelectedAccountReducer(base: AccountsReducer(base: self))
  }
}

private struct AccountsReducer<
  Base: ReducerProtocol<AppReducer.State, AppReducer.Action>
>: ReducerProtocol {
  let base: Base

  @Dependency(\.accountBookmarksClient) var accountBookmarks
  @Dependency(\.accountsClient) var accounts
  @Dependency(\.credentialsClient) var credentials

  public var body: some ReducerProtocol<AppReducer.State, AppReducer.Action> {
    self.base
      .forEach(\.availableAccounts, action: /Action.account) {
        AccountReducer()
      }
      // Save the selected account when it changes…
      .onChange(of: \.currentUser) { currentUser, _, _ in
        guard let currentUser else {
          return .none
        }
        return .fireAndForget {
          try await self.accountBookmarks.selectBookmark(currentUser)
        }
      }

    self.core
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case let .availableAccountsChanged(accounts):
        // If we haven't set currentUser or it isn't available in accounts anymore, let's select
        // the first available account.
        if
          state.currentUser.map({ jid in accounts.contains(jid) }) != true,
          let account = accounts.first
        {
          state.currentUser = account
        }

        var effects = [EffectTask<Action>]()

        for var account in state.availableAccounts where !accounts.contains(account.jid) {
          effects.append(
            AccountReducer().reduce(into: &account, action: .onAccountRemoved)
              .map { Action.account(account.jid, $0) }
          )
        }
        state.availableAccounts.removeAll(where: { !accounts.contains($0.jid) })

        for jid in accounts where state.availableAccounts[id: jid] == nil {
          effects.append(
            .task {
              await .accountAdded(TaskResult {
                let settings = try await self.accounts.client(jid).loadAccountSettings()
                return Account(jid: jid, status: .connecting, settings: settings)
              })
            }
          )
        }

        if state.availableAccounts.isEmpty {
          state.mainState = nil
        }

        if accounts.isEmpty {
          // Set the state conditionally so that controls don't lose focus in case the auth form
          // is visible already.
          if state.auth == nil {
            state.auth = .init()
          }
        }

        return .merge(effects)

      case var .accountAdded(.success(account)):
        let effect = AccountReducer().reduce(into: &account, action: .onAccountAdded)
          .map { Action.account(account.id, $0) }
        state.availableAccounts[id: account.id] = account

        if state.mainState == nil, state.currentUser == account.id {
          state.mainState = .init()
          state.auth = nil
        }

        return effect

      case let .accountAdded(.failure(error)):
        logger.error("Failed to add account. \(error)")
        return .none

      case .connectivityChanged(.online):
        return .fireAndForget { [accounts = state.availableAccounts] in
          for account in accounts {
            guard let credentials = try self.credentials.loadCredentials(account.jid) else {
              continue
            }
            self.accounts.reconnectAccount(credentials, true)
          }
        }

      default:
        return .none
      }
    }
  }
}
