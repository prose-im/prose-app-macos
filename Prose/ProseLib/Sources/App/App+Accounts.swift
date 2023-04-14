//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import BareMinimum
import ComposableArchitecture
import Foundation
import ProseBackend

extension ReducerProtocol<App.State, App.Action> {
  func handleAccounts() -> some ReducerProtocol<App.State, App.Action> {
    Accounts(base: self)
  }
}

private struct Accounts<
  Base: ReducerProtocol<App.State, App.Action>
>: ReducerProtocol {
  let base: Base

  @Dependency(\.accountsClient) var accounts
  @Dependency(\.credentialsClient) var credentials

  public var body: some ReducerProtocol<App.State, App.Action> {
    self.base
      .forEach(\.availableAccounts, action: /Action.account) {
        AccountReducer()
      }

    self.core
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case let .availableAccountsChanged(accounts):
        #warning("Save & restore selected account")
        if let account = accounts.first {
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
          var account = Account(jid: jid, status: .connecting)
          effects.append(
            AccountReducer().reduce(into: &account, action: .onAccountAdded)
              .map { Action.account(jid, $0) }
          )
          state.availableAccounts[id: jid] = account
        }

        if accounts.isEmpty {
          state.mainState = .init()
          state.auth = .init()
        }

        return .merge(effects)

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

struct AccountReducer: ReducerProtocol {
  typealias State = Account

  enum Action: Equatable {
    case onAccountAdded
    case onAccountRemoved

    case connectionStatusChanged(ConnectionStatus)

    case profileResponse(TaskResult<UserProfile?>)
    case contactsResponse(TaskResult<[Contact]>)
    case avatarResponse(TaskResult<URL?>)
  }

  enum EffectToken: Hashable, CaseIterable {
    case observeConnectionStatus
    case loadProfile
    case loadContacts
    case loadAvatar
  }

  @Dependency(\.accountsClient) var accounts
  @Dependency(\.credentialsClient) var credentials

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAccountAdded:
        print("ACCOUNT ADDED", state.jid)

        return .run { [jid = state.jid] send in
          for try await status in try self.accounts.client(jid).connectionStatus() {
            await send(.connectionStatusChanged(status))
          }
        }.cancellable(id: EffectToken.observeConnectionStatus)

      case .onAccountRemoved:
        return .cancel(token: EffectToken.self)

      case let .connectionStatusChanged(status):
        print("Connection status changed", status)
        defer {
          state.status = status
        }

        // If an account suddenly turns into an error state we try to reconnect it. This happens
        // with a backoff in the AccountsClient. If that fails the status will switch to
        // disconnected in which case we won't try again unless we detect that the connectivity
        // changes to online. If the account's status is .disconnected our user has the chance to
        // click the "Reconnect" button in the offline banner.
        if status.isError, !state.status.isError {
          return .fireAndForget { [jid = state.jid] in
            if let credentials = try self.credentials.loadCredentials(jid) {
              self.accounts.reconnectAccount(credentials, true)
            }
          }
        }

        if status == .connected, state.status != .connected {
          let jid = state.jid

          return .merge(
            .task {
              await .profileResponse(TaskResult {
                try await self.accounts.client(jid).loadProfile(jid)
              })
            }.cancellable(id: EffectToken.loadProfile),
            .task {
              await .contactsResponse(TaskResult {
                try await self.accounts.client(jid).loadContacts()
              })
            }.cancellable(id: EffectToken.loadContacts),
            .task {
              await .avatarResponse(TaskResult {
                try await self.accounts.client(jid).loadAvatar(jid)
              })
            }.cancellable(id: EffectToken.loadAvatar)
          )
        }

        return .none

      case let .profileResponse(.success(profile)):
        print("Received profile", profile)
        state.profile = profile
        return .none

      case let .contactsResponse(.success(contacts)):
        print("Received contacts", contacts)
        state.contacts = contacts
        return .none

      case let .avatarResponse(.success(avatar)):
        print("Received avatar", avatar)
        state.avatar = avatar
        return .none

      case let .profileResponse(.failure(error)):
        logger.error("Failed to load user profile: \(error.localizedDescription)")
        return .none

      case let .contactsResponse(.failure(error)):
        logger.error("Failed to load roster: \(error.localizedDescription)")
        return .none

      case let .avatarResponse(.failure(error)):
        logger.error("Failed to load user avatar: \(error.localizedDescription)")
        return .none
      }
    }
  }
}
