//
//  AppScene.swift
//  Prose
//
//  Created by Valerian Saliou on 9/14/21.
//

import AuthenticationFeature
import ComposableArchitecture
import MainWindowFeature
import SettingsFeature
import SwiftUI

public struct AppScene: Scene {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private let store: Store<AppState, AppAction>
    private var actions: ViewStore<Void, AppAction> { ViewStore(self.store.stateless) }

    @SwiftUI.State var authWindow: NSWindow?
    @SwiftUI.State var mainWindow: NSWindow?

    public init(store: Store<AppState, AppAction>) {
        self.store = store
    }

    public init() {
        self.init(store: Store(
            initialState: AppState(
                route: .auth(.basicAuth(.init()))
            ),
            reducer: appReducer,
            environment: AppEnvironment.live
        ))
    }

    public var body: some Scene {
        WithViewStore(self.store.scope(state: \.route.tag)) { viewStore in
            Group {
                login()
                    .handlesExternalEvents(matching: Set(arrayLiteral: "login"))
                    .onChange(of: authWindow) { newValue in
                        guard let window = newValue else { return }

                        // Disable green "zoom" (show fullscreen) button
                        window.standardWindowButton(.zoomButton)?.isEnabled = false
                    }
                main()
                    .handlesExternalEvents(matching: Set(arrayLiteral: "main"))
            }
            .onChange(of: viewStore.state) { newRoute in
                switch newRoute {
                case .auth:
                    mainWindow?.close()
                case .main:
                    authWindow?.close()
                }
            }
        }
    }

    @SceneBuilder
    private func main() -> some Scene {
        WindowGroup {
            IfLetStore(self.store.scope(
                state: (\AppState.route).case(/AppRoute.main),
                action: AppAction.main
            )) { store in
                MainScreen(store: store)
            }
            .frame(minWidth: 1_280, minHeight: 720)
            .background(WindowAccessor(window: $mainWindow))
        }
        .windowStyle(DefaultWindowStyle())
        .windowToolbarStyle(UnifiedWindowToolbarStyle())
        .commands {
            SidebarCommands()
            AppSettings()
        }
    }

    @SceneBuilder
    private func login() -> some Scene {
        WindowGroup {
            IfLetStore(
                self.store.scope(
                    state: (\AppState.route).case(/AppRoute.auth),
                    action: AppAction.auth
                ),
                then: AuthenticationScreen.init(store:)
            )
            .frame(width: 440)
            .background(WindowAccessor(window: $authWindow))
        }
        .windowStyle(.hiddenTitleBar)
    }
}
