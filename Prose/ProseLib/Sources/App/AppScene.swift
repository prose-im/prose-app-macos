//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AuthenticationFeature
import ComposableArchitecture
import MainWindowFeature
import SettingsFeature
import SwiftUI

public struct AppScene: Scene {
  private let store: Store<AppState, AppAction>
  private var actions: ViewStore<Void, AppAction> { ViewStore(self.store.stateless) }

  public init(store: Store<AppState, AppAction> = Store(
    initialState: AppState(),
    reducer: appReducer,
    environment: AppEnvironment.live
  )) {
    self.store = store
  }

  public var body: some Scene {
    WindowGroup {
      WithViewStore(self.store.scope(state: \.auth)) { authViewStore in
        WithViewStore(
          self.store
            .scope(state: \.isMainWindowRedacted)
        ) { isMainWindowRedacted in
          MainScreen(store: self.store.scope(state: \.main, action: AppAction.main))
            .redacted(reason: isMainWindowRedacted.state ? .placeholder : [])
            .frame(minWidth: 1280, minHeight: 720)
            .onAppear { actions.send(.onAppear) }
            .sheet(unwrapping: .constant(authViewStore.state)) { $state in
              AuthenticationScreen(store: self.store.scope(
                state: { _ in $state.wrappedValue },
                action: AppAction.auth
              ))
            }
        }
      }
    }
    .windowStyle(DefaultWindowStyle())
    .windowToolbarStyle(UnifiedWindowToolbarStyle())
    .commands {
      SidebarCommands()
    }
    Settings {
      SettingsView()
    }
  }
}
