//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import AuthenticationFeature
import Combine
import ComposableArchitecture
import ConnectivityClient
import CredentialsClient
import Foundation
import MainScreenFeature
import NotificationsClient
import Toolbox

struct AppReducer: ReducerProtocol {
  struct State: Equatable {
    var initialized = false
    var connectivity = Connectivity.online

    var currentUser: BareJid?
    var availableAccounts = IdentifiedArrayOf<Account>()

    var mainState: MainScreenReducer.MainScreenState?
    var auth: AuthenticationReducer.State?

    public init() {}
  }

  public enum Action: Equatable {
    case onAppear
    case dismissAuthenticationSheet

    case availableAccountsChanged(Set<BareJid>)
    case connectivityChanged(Connectivity)

    case auth(AuthenticationReducer.Action)
    case main(MainScreenReducer.Action)
    case account(BareJid, AccountReducer.Action)
  }

  private enum EffectToken: Hashable, CaseIterable {
    case observeAvailableAccounts
    case observeConnectivity
  }

  @Dependency(\.accountBookmarksClient) var accountBookmarks
  @Dependency(\.accountsClient) var accounts
  @Dependency(\.connectivityClient) var connectivityClient
  @Dependency(\.credentialsClient) var credentials
  @Dependency(\.notificationsClient) var notifications

  public var body: some ReducerProtocol<State, Action> {
    self.core
      .ifLet(\.main, action: /Action.main) {
        MainScreenReducer()
      }
      .ifLet(\.auth, action: /Action.auth) {
        AuthenticationReducer()
      }
      .handleAccounts()
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear where !state.initialized:
        state.initialized = true

        var effects: [EffectTask<Action>] = [
          .fireAndForget {
            self.notifications.promptForPushNotifications()
          },
          .run { send in
            for try await accounts in self.accounts.availableAccounts() {
              await send(.availableAccountsChanged(accounts))
            }
          }.cancellable(id: EffectToken.observeAvailableAccounts),
          .run { send in
            for try await connectivity in self.connectivityClient.connectivity() {
              await send(.connectivityChanged(connectivity))
            }
          }.cancellable(id: EffectToken.observeConnectivity),
        ]

        do {
          let bookmarks = try self.accountBookmarks.loadBookmarks()
          let credentials = try bookmarks.lazy.map(\.jid)
            .compactMap(self.credentials.loadCredentials)

          state.currentUser = bookmarks.first(where: \.isSelected)?.jid

          if credentials.isEmpty {
            state.auth = .init()
          } else {
            effects.append(
              .fireAndForget {
                self.accounts.connectAccounts(credentials)
              }
            )
          }
        } catch {
          logger.error("Error when loading credentials: \(error.localizedDescription)")
          state.auth = .init()
        }

        return .merge(effects)

      case let .connectivityChanged(connectivity):
        state.connectivity = connectivity
        return .none

      case .dismissAuthenticationSheet:
        if state.availableAccounts.isEmpty {
          // We don't have a valid account and the user wants to dismiss the authentication sheet.
          exit(0)
        }
        state.auth = nil
        return .none

      case let .auth(.didLogIn(jid)):
        state.auth = nil
        state.currentUser = jid
        return .none

      case .onAppear, .auth, .main, .availableAccountsChanged, .account:
        return .none
      }
    }
  }
}

extension AppReducer.State {
  var main: MainScreenReducer.State? {
    get {
      guard let mainState = self.mainState else {
        return .none
      }

      guard
        let currentUser = self.currentUser,
        self.availableAccounts[id: currentUser] != nil
      else {
        fatalError("""
          We do have MainState set however there's either no currentUser or a mismatch between
          currentUser and availableAccounts.
        """)
      }

      return .init(
        currentUser: currentUser,
        accounts: self.availableAccounts,
        childState: mainState
      )
    }

    set {
      self.mainState = newValue?.childState
      self.currentUser = newValue?.currentUser
    }
  }
}
