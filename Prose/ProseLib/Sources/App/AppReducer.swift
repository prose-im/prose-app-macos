#if canImport(AppKit)
    import AppKit
#endif
import AuthenticationFeature
import Combine
import ComposableArchitecture
import Foundation
import MainWindowFeature
// import ProseCore
import SharedModels

// MARK: - The Composable Architecture

// MARK: Reducer

public let appReducer: Reducer<
    AppState,
    AppAction,
    AppEnvironment
> = Reducer.combine([
    authenticationReducer._pullback(
        state: (\AppState.route).case(/AppRoute.auth),
        action: /AppAction.auth,
        environment: \AppEnvironment.auth
    ),
    mainWindowReducer._pullback(
        state: (\AppState.route).case(/AppRoute.main),
        action: /AppAction.main,
        environment: \AppEnvironment.main
    ),
    Reducer { state, action, environment in
        switch action {
        case .onAppear:
            guard case .auth = state.route else { return .none }

            guard let jid = environment.userDefaults.loadCurrentAccount() else { return .none }

            do {
                guard let password = try environment.credentials.loadCredentials(jid) else { return .none }
                return Effect(value: .auth(.didLogIn(jid: jid, password: password)))
            } catch {
                // TODO: Handle this error, user might have denied access to the credentials
                print("Error when loading credentials: \(error.localizedDescription)")
                return .none
            }

        case let .didLogIn(jid):
            state.route = .main(MainScreenState(
                sidebar: .init(
                    credentials: .init(jid: jid),
                    footer: .init(
                        avatar: .init(
                            // TODO: Use a JID type, to avoid this parsing
                            // TODO: Use an image stored by the user (not a preview asset)
                            avatar: "avatars/\(jid.node ?? "valerian")"
                        )
                    )
                )
            ))

        case let .auth(.didLogIn(jid, password)):
            do {
                environment.userDefaults.saveCurrentAccount(jid)
                try environment.credentials.save(jid, password)

                let url = URL(staticString: "prose://main")
                return environment.openURL(url, .init())
                    .receive(on: environment.mainQueue)
                    .map { AppAction.didLogIn(jid: jid) }
                    .mapError(EquatableError.init)
                    .catch { error -> AnyPublisher<AppAction, Never> in
                        fatalError("Failed to open URL <\(url.absoluteString)>: \(error.localizedDescription)")
                    }
                    .eraseToEffect()
            } catch {
                fatalError("Failed to store credentials for '\(jid)': \(error.localizedDescription)")
            }

        default:
            break
        }

        return .none
    },
])

// MARK: State

public struct AppState: Equatable {
    var route: AppRoute

    public init(
        route: AppRoute = .main(MainScreenState(
            // FIXME: [Rémi Bardon] Remove this fake data
            sidebar: .init(
                credentials: .init(jid: "example@prose.org"),
                footer: .init(avatar: .init(avatar: "avatars/valerian"))
            )
        ))
    ) {
        self.route = route
    }
}

public enum URLOpeningError: Error, Equatable {
    case failedToOpen(EquatableError)
}

// MARK: Actions

public enum AppAction: Equatable {
    case onAppear
    case didLogIn(jid: JID)
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
