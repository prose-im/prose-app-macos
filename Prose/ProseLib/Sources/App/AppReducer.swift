#if canImport(AppKit)
    import AppKit
#endif
import AuthenticationFeature
import Combine
import ComposableArchitecture
import CredentialsClient
import Foundation
import MainWindowFeature
// import ProseCore
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
        action: /AppAction.auth,
        environment: { $0.auth }
    ),
    mainWindowReducer.optional().pullback(
        state: \AppState.main,
        action: /AppAction.main,
        environment: { $0.main }
    ),
    Reducer { state, action, environment in
        func proceedToMainFlow(with credentials: Credentials) {
            // NOTE: [@nesium] This thing here should receive a nicer initializer sometime.
            state.main = MainScreenState(
                sidebar: .init(
                    credentials: .init(jid: credentials.jid),
                    footer: .init(
                        avatar: .init(
                            // TODO: Use a JID type, to avoid this parsing
                            // TODO: Use an image stored by the user (not a preview asset)
                            avatar: "avatars/\(credentials.jid.node ?? "valerian")"
                        )
                    )
                )
            )
            state.auth = nil
        }

        func proceedToLogin() {
            state.auth = .init(
                route: .basicAuth(.init(
                    jid: environment.userDefaults.loadCurrentAccount()?.rawValue ?? ""
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
            return .none

        case .authenticationResult(.success(.none)):
            proceedToLogin()
            return .none

        case let .authenticationResult(.failure(error)):
            print("Error when loading credentials: \(error.localizedDescription)")
            proceedToLogin()
            return .none

        case let .auth(.didLogIn(credentials)):
            proceedToMainFlow(with: credentials)
            return .fireAndForget {
                environment.userDefaults.saveCurrentAccount(credentials.jid)
                do {
                    try environment.credentials.save(credentials)
                } catch {
                    print("Failed to store credentials for '\(credentials.jid)': \(error.localizedDescription)")

                    // NOTE: [Rémi Bardon] Let's do nothing else here. For explanation,
                    //       see <https://github.com/prose-im/prose-app-macos/pull/37#discussion_r898929025>.
                }
            }

        case .onAppear, .auth, .main:
            return .none
        }
    },
])

// MARK: State

public struct AppState: Equatable {
    var hasAppearedAtLeastOnce: Bool

    var main: MainScreenState?
    var auth: AuthenticationState?

    public init(
        hasAppearedAtLeastOnce: Bool = false,
        main: MainScreenState? = nil,
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

    var mainQueue: AnySchedulerOf<DispatchQueue>

    var openURL: (URL, OpenURLConfiguration) -> Effect<Void, URLOpeningError>

    var auth: AuthenticationEnvironment
    var main: MainScreenEnvironment

    private init(
        userDefaults: UserDefaultsClient,
        credentials: CredentialsClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        openURL: @escaping (URL, OpenURLConfiguration) -> Effect<Void, URLOpeningError>,
        auth: AuthenticationEnvironment,
        main: MainScreenEnvironment
    ) {
        self.userDefaults = userDefaults
        self.credentials = credentials
        self.mainQueue = mainQueue
        self.openURL = openURL
        self.auth = auth
        self.main = main
    }

    public static var live: Self {
        let credentialsClient = CredentialsClient.live(service: "org.prose.Prose")
        return Self(
            userDefaults: .live(.standard),
            credentials: credentialsClient,
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
            },
            auth: .init(
                credentials: credentialsClient,
                mainQueue: .main
            ),
//            auth: .init(login: { jid, password, origin in
//                Effect.catching {
//                    try ProseCore.login(jid: jid, password: password, origin: origin)
//                }
//                .mapError(EquatableError.init)
//                .catchToEffect()
//            }),
            main: .init(
                sidebar: .stub
            )
        )
    }
}

public extension AppEnvironment {
    static var placeholder: AppEnvironment {
        AppEnvironment(
            userDefaults: .placeholder,
            credentials: .placeholder,
            mainQueue: .main,
            openURL: { _, _ in Effect(value: ()) },
            auth: .placeholder,
            main: .placeholder
        )
    }
}
