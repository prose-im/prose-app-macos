//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import BareMinimum
import ComposableArchitecture
import CredentialsClient
import Foundation
import NotificationsClient
import ProseCore

extension ReducerProtocol<AppReducer.State, AppReducer.Action> {
  func handleAccounts() -> some ReducerProtocol<AppReducer.State, AppReducer.Action> {
    AccountsReducer(base: self)
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
          var account = Account(jid: jid, status: .connecting)
          effects.append(
            AccountReducer().reduce(into: &account, action: .onAccountAdded)
              .map { Action.account(jid, $0) }
          )
          state.availableAccounts[id: jid] = account
        }

        if accounts.isEmpty {
          // Set the state conditionally so that controls don't lose focus in case the auth form
          // is visible already.
          if state.auth == nil {
            state.mainState = nil
            state.auth = .init()
          }
        } else {
          if state.mainState == nil {
            state.mainState = .init()
            state.auth = nil
          }
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
    case contactDidChange(BareJid)
    case messagesAppended(conversation: BareJid, messageIds: [MessageId])

    case profileResponse(TaskResult<UserProfile?>)
    case contactsResponse(TaskResult<[Contact]>)
    case avatarResponse(TaskResult<URL?>)
    case loadMessagesResponse(TaskResult<[Message]>)
  }

  enum EffectToken: Hashable {
    case observeConnectionStatus(BareJid)
    case observeEvents(BareJid)
    case loadProfile(BareJid)
    case loadContacts(BareJid)
    case loadAvatar(BareJid)
    case loadMessages(BareJid)
  }

  @Dependency(\.accountsClient) var accounts
  @Dependency(\.credentialsClient) var credentials
  @Dependency(\.notificationsClient) var notifications

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAccountAdded:
        return .run { [jid = state.jid] send in
          for try await status in try self.accounts.client(jid).connectionStatus() {
            await send(.connectionStatusChanged(status))
          }
        }.cancellable(id: EffectToken.observeConnectionStatus(state.jid))

      case .onAccountRemoved:
        // Since this is a forEach reducer (for each account) but effects can only be cancelled
        // globally, we need to distinguish our effects per account.
        return .cancel(ids: [
          EffectToken.observeConnectionStatus(state.jid),
          EffectToken.observeEvents(state.jid),
          EffectToken.loadProfile(state.jid),
          EffectToken.loadContacts(state.jid),
          EffectToken.loadAvatar(state.jid),
          EffectToken.loadMessages(state.jid),
        ])

      case let .connectionStatusChanged(status):
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
            }.cancellable(id: EffectToken.loadProfile(state.jid)),
            .task {
              await .contactsResponse(TaskResult {
                try await self.accounts.client(jid).loadContacts()
              })
            }.cancellable(id: EffectToken.loadContacts(state.jid)),
            .task {
              await .avatarResponse(TaskResult {
                try await self.accounts.client(jid).loadAvatar(jid)
              })
            }.cancellable(id: EffectToken.loadAvatar(state.jid)),
            .run { send in
              let events = try self.accounts.client(jid).events()
              for try await event in events {
                switch event {
                case let .contactChanged(jid):
                  await send(.contactDidChange(jid))
                case let .messagesAppended(conversation, messageIds):
                  await send(.messagesAppended(conversation: conversation, messageIds: messageIds))
                default:
                  break
                }
              }
            }.cancellable(id: EffectToken.observeEvents(state.jid), cancelInFlight: true)
          )
        }

        return .none

      case .contactDidChange:
        return .task { [jid = state.jid] in
          await .contactsResponse(TaskResult {
            try await self.accounts.client(jid).loadContacts()
          })
        }.cancellable(id: EffectToken.loadContacts(state.jid), cancelInFlight: true)

      case let .messagesAppended(conversation, messageIds):
        return .task { [jid = state.jid] in
          await .loadMessagesResponse(TaskResult {
            try await self.accounts.client(jid).loadMessagesWithIds(conversation, messageIds)
          })
        }

      case let .profileResponse(.success(profile)):
        state.profile = profile
        return .none

      case let .contactsResponse(.success(contacts)):
        state.contacts = contacts
        return .none

      case let .avatarResponse(.success(avatar)):
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

      case let .loadMessagesResponse(.success(messages)):
        return .fireAndForget { [account = state] in
          for message in messages where message.from != account.jid {
            try await self.notifications.scheduleLocalNotification(
              message,
              account.userInfo(for: message.from)
            )
          }
        }

      case let .loadMessagesResponse(.failure(error)):
        logger.error("Failed to load messages. \(error.localizedDescription)")
        return .none
      }
    }
  }
}

private extension Account {
  func userInfo(for jid: BareJid) -> UserInfo {
    guard let profile = self.contacts.first(where: { $0.jid == jid }) else {
      return UserInfo(jid: jid, name: jid.rawValue)
    }
    return UserInfo(jid: profile.jid, name: profile.name, avatar: profile.avatar)
  }
}
