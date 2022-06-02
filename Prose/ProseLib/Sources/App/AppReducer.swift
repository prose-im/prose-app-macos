import AuthenticationFeature
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
])

// MARK: State

public struct AppState: Equatable {
    var route: AppRoute

    public init(
        route: AppRoute = .main(MainWindowState(
            sidebar: .init(credentials: .init(jid: "example@prose.org"))
        ))
    ) {
        self.route = route
    }
}

// MARK: Actions

public enum AppAction: Equatable {
    case auth(AuthenticationAction)
    case main(MainWindowAction)
}

// MARK: Environment

public struct AppEnvironment: Equatable {
    var auth: AuthenticationEnvironment
    var main: MainWindowEnvironment

    private init(
        auth: AuthenticationEnvironment,
        main: MainWindowEnvironment
    ) {
        self.auth = auth
        self.main = main
    }

    public static var live: Self {
        Self(
            auth: .init(),
//            auth: .init(login: { jid, password, origin in
//                Effect.catching {
//                    try ProseCore.login(jid: jid, password: password, origin: origin)
//                }
//                .mapError(EquatableError.init)
//                .catchToEffect()
//            }),
            main: .init()
        )
    }
}
