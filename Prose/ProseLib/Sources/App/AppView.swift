// import AuthenticationFeature
import ComposableArchitecture
import SidebarFeature
import SwiftUI
import TcaHelpers

struct AuthenticationView: View {
    let store: Store<AuthenticationState, AuthenticationAction>

    var body: some View {
        Text("Implement me")
    }
}

public struct AppView: View {
    private let store: Store<AppState, AppAction>

    public init() {
        self.store = Store(
            initialState: AppState(),
            reducer: appReducer,
            environment: .live()
        )
    }

    public var body: some View {
        WithViewStore(self.store.scope(state: \AppState.route)) { route in
            switch route.state {
            case .auth:
                IfLetStore(
                    self.store.scope(
                        state: (\AppState.route).case(/AppState.Route.auth),
                        action: AppAction.auth
                    ),
                    then: { store in
                        AuthenticationView(store: store)
                    }
                )

            case .main:
                IfLetStore(
                    self.store.scope(
                        state: (\AppState.route).case(/AppState.Route.main),
                        action: AppAction.main
                    ),
                    then: { store in
                        NavigationView {
                            SidebarView(store: store)
                                .frame(minWidth: 280.0)
                            Text("Nothing to show here 🤷")
                        }
                        .listStyle(SidebarListStyle())
                    }
                )
            }
        }
        .frame(minWidth: 1_280, minHeight: 720)
    }
}
