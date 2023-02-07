import AccountBookmarksClient
import AuthenticationFeature
import Combine
import ComposableArchitecture
import CredentialsClient
import Foundation
import MainWindowFeature
import NotificationsClient
import ProseCore
import ProseCoreTCA
import struct ProseCoreTCA.ProseClient
import Toolbox

struct App: ReducerProtocol {
  struct State: Equatable {
    var hasAppearedAtLeastOnce = false

    var main: SessionState<MainScreenState> = .placeholder
    var auth: Authentication.State?

    var isMainWindowEnabled: Bool { self.auth == nil }
    /// - Note: When we'll support multi-account, we'll need to make this a regular value,
    ///         as we don't want to redact the view when the user adds a new account.
    var isMainWindowRedacted: Bool { self.auth != nil }

    public init() {}
  }

  public enum Action: Equatable {
    case onAppear
    case dismissAuthenticationSheet

    case authenticationResult(TaskResult<[Credentials]>)
    case connectionResult(Result<None, EquatableError>)
    case didReceiveMessage(Message, UserInfo)
    case currentUserInfoChanged(UserInfo)

    case auth(Authentication.Action)
    case main(MainScreenAction)
  }

  private enum EffectToken: Hashable, CaseIterable {
    case observeCurrentUserInfo
  }
  
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
    
    ConditionallyEnable(when: \.isMainWindowEnabled) {
      Scope(state: \.main, action: /Action.main) {
        Reduce(
          mainWindowReducer,
          environment: .init(
            proseClient: self.legacyProseClient,
            pasteboard: pasteboard,
            mainQueue: self.mainQueue
          )
        )
      }
    }
  }
  
  #warning("Handle logout")

  @ReducerBuilder<State, Action>
  private var core: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      func proceedToMainFlow(with credentials: Credentials) -> EffectTask<Action> {
        state.main = SessionState(
          currentUser: .init(jid: credentials.jid),
          childState: MainScreenState()
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

      func proceedToLogin(jid: JID? = nil) -> EffectTask<Action> {
        state.auth = .init()
        return .cancel(id: EffectToken.observeCurrentUserInfo)
      }

      switch action {
      case .onAppear where !state.hasAppearedAtLeastOnce:
        state.hasAppearedAtLeastOnce = true

        return .merge(
          .fireAndForget {
            self.notifications.promptForPushNotifications()
          },
          .task {
            await .authenticationResult(
              TaskResult {
                try self.accountBookmarks.loadBookmarks()
                  .lazy
                  .map(\.jid)
                  .compactMap(self.credentials.loadCredentials)
              }
            )
          }

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
        )
      
      case let .authenticationResult(.success(credentials)) where credentials.isEmpty:
        return proceedToLogin()

      case let .authenticationResult(.success(credentials)):
        return .none
//        return .merge(
//          proceedToMainFlow(with: credentials),
//          environment.proseClient.login(credentials.jid, credentials.password)
//            .receive(on: environment.mainQueue)
//            .catchToEffect()
//            .map(AppAction.connectionResult)
//        )

      case let .authenticationResult(.failure(error)):
        logger.error("Error when loading credentials: \(error.localizedDescription)")
        return proceedToLogin()

      case let .auth(.didLogIn(credentials)):
        return proceedToMainFlow(with: credentials)

      case .connectionResult(.success):
        logger.info("Connection established.")
        return .none

      case .connectionResult(.failure):
        return proceedToLogin()

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

      case .onAppear, .auth, .main:
        return .none
      }
    }
  }
}

struct ConditionallyEnable<State, Action, Child: ReducerProtocol>: ReducerProtocol
  where State == Child.State, Action == Child.Action {

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

// public let appReducer: AnyReducer<
//  AppState,
//  AppAction,
//  AppEnvironment
// > = AnyReducer.combine([
//  AnyReducer { state, action, environment in
//
//  },
//  authenticationReducer.optional().pullback(
//    state: \AppState.auth,
//    action: CasePath(AppAction.auth),
//    environment: { $0.auth }
//  ),
//  mainWindowReducer.pullback(
//    state: \AppState.main,
//    action: CasePath(AppAction.main),
//    environment: { $0.main }
//  ).disabled(when: \.isMainWindowDisabled),
// ])
