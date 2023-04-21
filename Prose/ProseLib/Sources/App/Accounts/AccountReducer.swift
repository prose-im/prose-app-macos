//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import ComposableArchitecture
import CredentialsClient
import Foundation
import NotificationsClient
import ProseCore

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
        return .merge(
          self.loadAccountData(account: state.jid, cachePolicy: .returnCacheDataDontLoad),
          .run { [jid = state.jid] send in
            for try await status in try self.accounts.client(jid).connectionStatus() {
              await send(.connectionStatusChanged(status))
            }
          }.cancellable(id: EffectToken.observeConnectionStatus(state.jid))
        )

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

          var effects: [EffectTask<Action>] = [
            self.loadAccountData(account: jid, cachePolicy: .default),
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
            }.cancellable(id: EffectToken.observeEvents(state.jid), cancelInFlight: true),
          ]

          if state.availability != .available {
            effects.append(.fireAndForget { [availability = state.availability] in
              try await self.accounts.client(jid).setAvailability(availability, nil)
            })
          }

          return .merge(effects)
        }

        return .none

      case let .contactDidChange(jid) where state.jid == jid:
        return self.loadAccountData(account: state.jid, cachePolicy: .default)

      case .contactDidChange:
        let id = UUID()
        return .task { [jid = state.jid] in
          await withTaskCancellation(id: EffectToken.loadContacts(jid), cancelInFlight: true) {
            await .contactsResponse(TaskResult {
              // Debounce loading contacts slightly…
              try await Task.sleep(for: .milliseconds(500))
              return try await self.accounts.client(jid).loadContacts(.default)
            })
          }
        }

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
        state.contacts = .init(
          zip(contacts.map(\.jid), contacts),
          uniquingKeysWith: { _, last in last }
        )
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
              account.contacts[message.from].map(UserInfo.init) ??
                UserInfo(jid: message.from, name: message.from.rawValue)
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

private extension AccountReducer {
  func loadAccountData(account: BareJid, cachePolicy: CachePolicy) -> EffectTask<Action> {
    .merge(
      .task {
        await .profileResponse(TaskResult {
          try await self.accounts.client(account).loadProfile(account, cachePolicy)
        })
      }.cancellable(id: EffectToken.loadProfile(account)),
      .task {
        await .contactsResponse(TaskResult {
          try await self.accounts.client(account).loadContacts(cachePolicy)
        })
      }.cancellable(id: EffectToken.loadContacts(account)),
      .task {
        await .avatarResponse(TaskResult {
          try await self.accounts.client(account).loadAvatar(account, cachePolicy)
        })
      }.cancellable(id: EffectToken.loadAvatar(account))
    )
  }
}
