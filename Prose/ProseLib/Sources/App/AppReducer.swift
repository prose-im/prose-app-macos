//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

#if canImport(AppKit)
  import AppKit
#endif
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
import UserDefaultsClient

// MARK: - The Composable Architecture

// MARK: Reducer

public let appReducer: AnyReducer<
  AppState,
  AppAction,
  AppEnvironment
> = AnyReducer.combine([
  AnyReducer { state, action, environment in
    func proceedToMainFlow(with credentials: Credentials) -> EffectTask<AppAction> {
      state.main = SessionState(
        currentUser: .init(jid: credentials.jid),
        childState: MainScreenState()
      )
      state.auth = nil

      return environment.proseClient.userInfos([credentials.jid])
        .catch { _ in Just([:]) }
        .compactMap { $0[credentials.jid] }
        .receive(on: environment.mainQueue)
        .eraseToEffect(AppAction.currentUserInfoChanged)
        .cancellable(id: AppEffectToken.observeCurrentUserInfo, cancelInFlight: true)
    }

    func proceedToLogin(jid: JID? = nil) -> EffectTask<AppAction> {
      state.auth = .init(
        route: .basicAuth(.init(
          jid: (jid ?? environment.userDefaults.loadCurrentAccount())?.rawValue ?? ""
        ))
      )
      return .cancel(id: AppEffectToken.observeCurrentUserInfo)
    }

    switch action {
    case .onAppear where !state.hasAppearedAtLeastOnce:
      state.hasAppearedAtLeastOnce = true

      return EffectTask.merge(
        EffectPublisher<Credentials?, EquatableError>.result {
          Result {
            try environment.userDefaults.loadCurrentAccount()
              .flatMap(environment.credentials.loadCredentials)
          }.mapError(EquatableError.init)
        }
        .catchToEffect()
        .map(AppAction.authenticationResult),

        .fireAndForget {
          environment.notifications.promptForPushNotifications()
        },

        environment.proseClient.incomingMessages()
          .flatMap { message in
            environment.proseClient.userInfos([message.from])
              .catch { _ in Just([:]) }
              .compactMap { userInfos in
                userInfos[message.from].map { (message: message, userInfo: $0) }
              }
              .prefix(1)
          }
          .receive(on: environment.mainQueue)
          .eraseToEffect()
          .map { args in AppAction.didReceiveMessage(args.message, args.userInfo) }
      )

    case let .authenticationResult(.success(.some(credentials))):
      return .merge(
        proceedToMainFlow(with: credentials),
        environment.proseClient.login(credentials.jid, credentials.password)
          .receive(on: environment.mainQueue)
          .catchToEffect()
          .map(AppAction.connectionResult)
      )

    case .authenticationResult(.success(.none)):
      return proceedToLogin()

    case let .authenticationResult(.failure(error)):
      logger.error("Error when loading credentials: \(error.localizedDescription)")
      return proceedToLogin()

    case let .auth(.didLogIn(credentials)):
      return .merge(
        proceedToMainFlow(with: credentials),
        .fireAndForget {
          environment.userDefaults.saveCurrentAccount(credentials.jid)
          do {
            try environment.credentials.save(credentials)
          } catch {
            logger
              .warning(
                "Failed to store credentials for '\(credentials.jid)': \(error.localizedDescription)"
              )

            // NOTE: [Rémi Bardon] Let's do nothing else here. For explanation,
            //       see
            //       <https://github.com/prose-im/prose-app-macos/pull/37#discussion_r898929025>.
          }
        }
      )

    case .main(.sidebar(.footer(.avatar(.signOutTapped)))):
      let jid = environment.userDefaults.loadCurrentAccount()

      if let jid = jid {
        do {
          try environment.credentials.deleteCredentials(jid)
        } catch {
          fatalError("Failed to sign out: \(error.localizedDescription)")
        }
      }

      environment.userDefaults.deleteCurrentAccount()

      return proceedToLogin(jid: jid)

    case .connectionResult(.success):
      logger.info("Connection established.")
      return .none

    case .connectionResult(.failure):
      return proceedToLogin()

    case let .didReceiveMessage(message, userInfo):
      return environment.notifications.scheduleLocalNotification(message, userInfo).fireAndForget()

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
  },
  authenticationReducer.optional().pullback(
    state: \AppState.auth,
    action: CasePath(AppAction.auth),
    environment: { $0.auth }
  ),
  mainWindowReducer.pullback(
    state: \AppState.main,
    action: CasePath(AppAction.main),
    environment: { $0.main }
  ).disabled(when: \.isMainWindowDisabled),
])

extension AnyReducer where State == AppState, Action == AppAction, Environment == AppEnvironment {
  func disabled(when isDisabled: @escaping (AppState) -> Bool) -> Self {
    AnyReducer { state, action, environment in
      guard !isDisabled(state) else {
        return .none
      }
      return self(&state, action, environment)
    }
  }
}

// MARK: State

public struct AppState: Equatable {
  var hasAppearedAtLeastOnce: Bool

  var main: SessionState<MainScreenState>
  var auth: AuthenticationState?

  var isMainWindowDisabled: Bool { self.auth != nil }
  /// - Note: When we'll support multi-account, we'll need to make this a regular value,
  ///         as we don't want to redact the view when the user adds a new account.
  var isMainWindowRedacted: Bool { self.auth != nil }

  public init(
    hasAppearedAtLeastOnce: Bool = false,
    main: SessionState<MainScreenState> = .placeholder,
    auth: AuthenticationState? = nil
  ) {
    self.hasAppearedAtLeastOnce = hasAppearedAtLeastOnce
    self.main = main
    self.auth = auth
  }
}

public enum URLOpeningError: Error, Equatable {
  case failedToOpen(EquatableError)
}

// MARK: Actions

public enum AppAction: Equatable {
  case onAppear
  case dismissAuthenticationSheet

  case authenticationResult(Result<Credentials?, EquatableError>)
  case connectionResult(Result<None, EquatableError>)
  case didReceiveMessage(Message, UserInfo)
  case currentUserInfoChanged(UserInfo)

  case auth(AuthenticationAction)
  case main(MainScreenAction)
}

enum AppEffectToken: Hashable, CaseIterable {
  case observeCurrentUserInfo
}
