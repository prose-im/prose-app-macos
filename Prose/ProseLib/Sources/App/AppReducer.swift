// import AuthenticationFeature
import ComposableArchitecture
import Foundation
// import ProseCore
import SharedModels
import SidebarFeature

public struct AuthenticationState: Equatable {}
public enum AuthenticationAction: Equatable {}

struct AppState: Equatable {
    var route: Route = .main(SidebarState(credentials: .init(jid: "Hello World")))
}

extension AppState {
    enum Route: Equatable {
        case auth(AuthenticationState)
        case main(SidebarState)
    }
}

enum AppAction {
    case auth(AuthenticationAction)
    case main(SidebarAction)
}

struct AppEnvironment {
    static func live() -> Self {
        .init()
    }
}

extension AppEnvironment {
    //  var auth: AuthenticationEnvironment {
//    .init(login: { jid, password, origin in
//      Effect.catching {
//        try ProseCore.login(jid: jid, password: password, origin: origin)
//      }
//      .mapError(EquatableError.init)
//      .catchToEffect()
//    })
    //  }

    var main: SidebarEnvironment {
        .init()
    }
}

let appReducer = Reducer.combine(
    //  authenticationReducer._pullback(
//    state: (\AppState.route).case(/AppState.Route.auth),
//    action: /AppAction.auth,
//    environment: \.auth
    //  ),
    sidebarReducer._pullback(
        state: (\AppState.route).case(/AppState.Route.main),
        action: /AppAction.main,
        environment: \.main
    ),
    Reducer<AppState, AppAction, AppEnvironment> { _, action, _ in
        switch action {
        case .auth, .main:
            return .none
        }
    }
)
