import AuthenticationFeature
import ComposableArchitecture
import Foundation

struct AppState: Equatable {
  var route: Route = .auth(AuthenticationState())
}

extension AppState {
  enum Route: Equatable {
    case auth(AuthenticationState)
    case main
  }
}

enum AppAction {
  case auth(AuthenticationAction)
}

struct AppEnvironment {
  static func live() -> Self {
    .init()
  }
}

extension AppEnvironment {
  var auth: AuthenticationEnvironment {
    AuthenticationEnvironment()
  }
}

let appReducer = Reducer.combine(
  authenticationReducer._pullback(
    state: (\AppState.route).case(/AppState.Route.auth),
    action: /AppAction.auth,
    environment: \.auth
  ),
  Reducer<AppState, AppAction, AppEnvironment> { state, action, _ in
    switch action {
    case .auth(.loginButtonTapped):
      state.route = .main
      return .none

    case .auth:
      return .none
    }
  }
)
