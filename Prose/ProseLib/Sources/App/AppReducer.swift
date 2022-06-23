#if canImport(AppKit)
    import AppKit
#endif
import AuthenticationFeature
import Combine
import ComposableArchitecture
import CredentialsClient
import Foundation
import MainWindowFeature
import ProseCoreTCA
import SharedModels
import UserDefaultsClient

// MARK: - The Composable Architecture

// MARK: Reducer

public let appReducer: Reducer<
    AppState,
    AppAction,
    AppEnvironment
> = Reducer.combine([
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
    Reducer { state, action, environment in
        func proceedToMainFlow(with credentials: Credentials) {
            state.main = MainScreenState(jid: credentials.jid)
            state.auth = nil
        }

        func proceedToLogin(jid: JID? = nil) {
            state.auth = .init(
                route: .basicAuth(.init(
                    jid: (jid ?? environment.userDefaults.loadCurrentAccount())?.rawValue ?? ""
                ))
            )
        }

        switch action {
        case .onAppear where !state.hasAppearedAtLeastOnce:
            state.hasAppearedAtLeastOnce = true
            return Effect<Credentials?, EquatableError>.result {
                Result {
                    try environment.userDefaults.loadCurrentAccount()
                        .flatMap(environment.credentials.loadCredentials)
                }.mapError(EquatableError.init)
            }
            .catchToEffect()
            .map(AppAction.authenticationResult)

        case let .authenticationResult(.success(.some(credentials))):
            proceedToMainFlow(with: credentials)
            return environment.proseClient.login(credentials.jid, credentials.password)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(AppAction.connectionResult)

        case .authenticationResult(.success(.none)):
            proceedToLogin()
            return .none

        case let .authenticationResult(.failure(error)):
            logger.error("Error when loading credentials: \(error.localizedDescription)")
            proceedToLogin()
            return .none

        case let .auth(.didLogIn(credentials)):
            proceedToMainFlow(with: credentials)
            return .fireAndForget {
                environment.userDefaults.saveCurrentAccount(credentials.jid)
                do {
                    try environment.credentials.save(credentials)
                } catch {
                    logger.warning("Failed to store credentials for '\(credentials.jid)': \(error.localizedDescription)")

                    // NOTE: [Rémi Bardon] Let's do nothing else here. For explanation,
                    //       see <https://github.com/prose-im/prose-app-macos/pull/37#discussion_r898929025>.
                }
            }

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

            proceedToLogin(jid: jid)
            return .none

        case .connectionResult(.success):
            print("Connection established.")
            return .none

        case .connectionResult(.failure):
            proceedToLogin()
            return .none

        case .onAppear, .auth, .main:
            return .none
        }
    },
])

extension Reducer where State == AppState, Action == AppAction, Environment == AppEnvironment {
    func disabled(when isDisabled: @escaping (AppState) -> Bool) -> Self {
        Reducer { state, action, environment in
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

    var main: MainScreenState
    var auth: AuthenticationState?

    var isMainWindowDisabled: Bool { self.auth != nil }
    /// - Note: When we'll support multi-account, we'll need to make this a regular value,
    ///         as we don't want to redact the view when the user adds a new account.
    var isMainWindowRedacted: Bool { self.auth != nil }

    public init(
        hasAppearedAtLeastOnce: Bool = false,
        main: MainScreenState = .placeholder,
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
    case authenticationResult(Result<Credentials?, EquatableError>)
    case connectionResult(Result<None, EquatableError>)
    case auth(AuthenticationAction)
    case main(MainScreenAction)
}

// MARK: Environment

#if canImport(AppKit)
    public typealias OpenURLConfiguration = NSWorkspace.OpenConfiguration
#else
    public typealias OpenURLConfiguration = Void
#endif

public struct AppEnvironment {
    var userDefaults: UserDefaultsClient
    var credentials: CredentialsClient

    var proseClient: ProseClient

    var mainQueue: AnySchedulerOf<DispatchQueue>

    var openURL: (URL, OpenURLConfiguration) -> Effect<Void, URLOpeningError>

    var auth: AuthenticationEnvironment {
        AuthenticationEnvironment(
            proseClient: self.proseClient,
            credentials: self.credentials,
            mainQueue: self.mainQueue
        )
    }

    var main: MainScreenEnvironment {
        MainScreenEnvironment(proseClient: self.proseClient, mainQueue: self.mainQueue)
    }

    public static var live: Self {
        Self(
            userDefaults: .live(.standard),
            credentials: .live(service: "org.prose.app"),
            proseClient: .live(),
            mainQueue: .main,
            openURL: { url, openConfig -> Effect<Void, URLOpeningError> in
                Effect.future { callback in
                    #if canImport(AppKit)
                        NSWorkspace.shared.open(url, configuration: openConfig) { _, error in
                            if let error = error {
                                callback(.failure(.failedToOpen(EquatableError(error))))
                            } else {
                                callback(.success(()))
                            }
                        }
                    #else
                        #error("AppKit is not available, find another way to open an URL.")
                    #endif
                }
            }
        )
    }
}
