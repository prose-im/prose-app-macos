import AccountBookmarksClient
import AppDomain
import AuthenticationFeature
import Combine
import ComposableArchitecture
import CredentialsClient
import Foundation
import MainScreenFeature
import NotificationsClient
import ProseCore
import ProseCoreTCA
import struct ProseCoreTCA.ProseClient
import Toolbox

struct App: ReducerProtocol {
  struct State: Equatable {
    var hasAppearedAtLeastOnce = false

    var main: SessionState<MainScreen.MainScreenState> = .placeholder
    var auth: Authentication.State?

    var isMainScreenEnabled: Bool { self.auth == nil }
    /// - Note: When we'll support multi-account, we'll need to make this a regular value,
    ///         as we don't want to redact the view when the user adds a new account.
    var isMainScreenRedacted: Bool { self.auth != nil }

    public init() {}
  }

  public enum Action: Equatable {
    case onAppear
    case dismissAuthenticationSheet

    case didReceiveMessage(Message, UserInfo)
    case currentUserInfoChanged(UserInfo)
    case availableAccountsChanged([Account])

    case auth(Authentication.Action)
    case main(MainScreen.Action)
  }

  private enum EffectToken: Hashable, CaseIterable {
    case observeCurrentUserInfo
    case observeAvailableAccounts
  }

  @Dependency(\.accountsClient) var accounts
  @Dependency(\.accountBookmarksClient) var accountBookmarks
  @Dependency(\.credentialsClient) var credentials
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.notificationsClient) var notifications
  @Dependency(\.pasteboardClient) var pasteboard
  @Dependency(\.legacyProseClient) var legacyProseClient

  public var body: some ReducerProtocol<State, Action> {
    self.core
      .ifLet(\.auth, action: /Action.auth) {
        Authentication()
      }

    ConditionallyEnable(when: \.isMainScreenEnabled) {
      Scope(state: \.main, action: /Action.main) {
        MainScreen()
      }
    }
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      func proceedToMainFlow(with jid: BareJid) -> EffectTask<Action> {
        state.main = SessionState(
          currentUser: .init(jid: jid),
          childState: MainScreen.MainScreenState()
        )
        state.auth = nil

        return .none

//        return environment.proseClient.userInfos([credentials.jid])
//          .catch { _ in Just([:]) }
//          .compactMap { $0[credentials.jid] }
//          .receive(on: environment.mainQueue)
//          .eraseToEffect(Action.currentUserInfoChanged)
//          .cancellable(id: EffectToken.observeCurrentUserInfo, cancelInFlight: true)
      }

      func proceedToLogin(jid _: JID? = nil) -> EffectTask<Action> {
        state.auth = .init()
        return .cancel(id: EffectToken.observeCurrentUserInfo)
      }

      switch action {
      case .onAppear where !state.hasAppearedAtLeastOnce:
        state.hasAppearedAtLeastOnce = true

        var effects: [EffectTask<Action>] = [
          .fireAndForget {
            self.notifications.promptForPushNotifications()
          },
          .run { send in
            for try await accounts in self.accounts.availableAccounts() {
              await send(.availableAccountsChanged(accounts))
            }
          }.cancellable(id: EffectToken.observeAvailableAccounts),
//          environment.proseClient.incomingMessages()
//            .flatMap { message in
//              environment.proseClient.userInfos([message.from])
//                .catch { _ in Just([:]) }
//                .compactMap { userInfos in
//                  userInfos[message.from].map { (message: message, userInfo: $0) }
//                }
//                .prefix(1)
//            }
//            .receive(on: environment.mainQueue)
//            .eraseToEffect()
//            .map { args in AppAction.didReceiveMessage(args.message, args.userInfo) }
        ]

        do {
          let credentials = try self.loadSavedCredentials()

          #warning("Save & restore selected account")
          if let firstCredentials = credentials.first {
            effects += [
              proceedToMainFlow(with: firstCredentials.jid),
              .fireAndForget {
                self.accounts.connectAccounts(credentials)
              },
            ]

          } else {
            effects.append(proceedToLogin())
          }
        } catch {
          logger.error("Error when loading credentials: \(error.localizedDescription)")
          return proceedToLogin()
        }

        return .merge(effects)

      case let .auth(.didLogIn(jid)):
        return proceedToMainFlow(with: jid)

      case let .didReceiveMessage(message, userInfo):
        return self.notifications.scheduleLocalNotification(message, userInfo)
          .fireAndForget()

      case let .currentUserInfoChanged(info):
        state.main = SessionState(currentUser: info, childState: state.main.childState)
        return .none

      case .dismissAuthenticationSheet:
        if state.main.childState.isPlaceholder {
          // We don't have a valid account and the user wants to dismiss the authentication sheet.
          exit(0)
        }
        state.auth = nil
        return .none

      case let .availableAccountsChanged(accounts):
        print("ACCOUNTS", accounts)
        if accounts.isEmpty {
          state.main = .placeholder
          return proceedToLogin()
        }
        return .none

      case .onAppear, .auth, .main:
        return .none
      }
    }
  }

  private func loadSavedCredentials() throws -> [Credentials] {
    try self.accountBookmarks.loadBookmarks()
      .lazy
      .map(\.jid)
      .compactMap(self.credentials.loadCredentials)
  }
}

struct ConditionallyEnable<State, Action, Child: ReducerProtocol>: ReducerProtocol
  where State == Child.State, Action == Child.Action
{
  let child: Child
  let enableWhen: KeyPath<Child.State, Bool>

  init(when: KeyPath<Child.State, Bool>, @ReducerBuilder<State, Action> _ child: () -> Child) {
    self.enableWhen = when
    self.child = child()
  }

  func reduce(into state: inout Child.State, action: Child.Action) -> EffectTask<Child.Action> {
    if state[keyPath: self.enableWhen] {
      return self.child.reduce(into: &state, action: action)
    }
    return .none
  }
}
