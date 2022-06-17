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
        case let .didLogIn(jid):
            state.route = .main(MainScreenState(
                sidebar: .init(
                    credentials: .init(jid: jid),
                    footer: .init(
                        avatar: .init(
                            // TODO: Use a JID type, to avoid this parsing
                            // TODO: Use an image stored by the user (not a preview asset)
                            avatar: "avatars/\(jid.split(separator: "@").first ?? "valerian")"
                        )
                    )
                )
            ))

        case let .auth(.didLogIn(jid, _)):
            let url = URL(staticString: "prose://main")
            return environment.openURL(url, .init())
                .receive(on: environment.mainQueue)
                .map { AppAction.didLogIn(jid: jid) }
                .mapError(EquatableError.init)
                .catch { error -> AnyPublisher<AppAction, Never> in
                    fatalError("Failed to open URL <\(url.absoluteString)>: \(error.localizedDescription)")
                }
                .eraseToEffect()

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
    // TODO: [Rémi Bardon] Change this to a type-safe JID
    case didLogIn(jid: String)
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
    var mainQueue: AnySchedulerOf<DispatchQueue>

    var openURL: (URL, OpenURLConfiguration) -> Effect<Void, URLOpeningError>

    var auth: AuthenticationEnvironment
    var main: MainScreenEnvironment

    private init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        openURL: @escaping (URL, OpenURLConfiguration) -> Effect<Void, URLOpeningError>,
        auth: AuthenticationEnvironment,
        main: MainScreenEnvironment
    ) {
        self.mainQueue = mainQueue
        self.openURL = openURL
        self.auth = auth
        self.main = main
    }

    public static var live: Self {
        Self(
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
