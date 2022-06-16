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
    private let store: Store<AppState, AppAction>
    private var actions: ViewStore<Void, AppAction> { ViewStore(self.store.stateless) }

    @SwiftUI.State var mainWindow: NSWindow?

    public init(store: Store<AppState, AppAction> = Store(
        initialState: AppState(),
        reducer: appReducer,
        environment: AppEnvironment.live
    )) {
        self.store = store
    }

    public var body: some Scene {
        mainWindowGroup()
    }

    private func mainWindowGroup() -> some Scene {
        WindowGroup {
            WithViewStore(self.store.scope(state: \.auth)) { authViewStore in
                IfLetStore(self.store.scope(state: \.main, action: AppAction.main)) { store in
                    MainScreen(store: store)
                } else: {
                    MainScreen(store: Store(
                        initialState: .placeholder,
                        reducer: Reducer.empty,
                        environment: MainScreenEnvironment.placeholder
                    ))
                    .redacted(reason: .placeholder)
                }
                .frame(minWidth: 1_280, minHeight: 720)
                .onAppear { actions.send(.onAppear) }
                .background(WindowAccessor(window: $mainWindow))
                .onChange(of: mainWindow) { newValue in
                    guard let window = newValue else { return }

                    window.makeKeyAndOrderFront(nil)
                }
                .sheet(unwrapping: .constant(authViewStore.state)) { $state in
                    AuthenticationScreen(store: self.store.scope(
                        state: { _ in $state.wrappedValue },
                        action: AppAction.auth
                    ))
                }
            }
        }
        .windowStyle(DefaultWindowStyle())
        .windowToolbarStyle(UnifiedWindowToolbarStyle())
        .commands {
            SidebarCommands()
            AppSettings()
        }
    }
}
