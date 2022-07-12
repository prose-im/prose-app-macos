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

  public init(store: Store<AppState, AppAction> = Store(
    initialState: AppState(),
    reducer: appReducer,
    environment: AppEnvironment.live
  )) {
    self.store = store
  }

  public var body: some Scene {
    WindowGroup {
      AppView(store: self.store)
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

public struct AppView: View {
  struct ViewState: Equatable {
    var isMainWindowRedacted: Bool
    var isAuthScreenPresented: Bool
  }

  private let store: Store<AppState, AppAction>
  @ObservedObject private var viewStore: ViewStore<ViewState, AppAction>

  public init(store: Store<AppState, AppAction>) {
    self.store = store
    self.viewStore = ViewStore(store.scope(state: ViewState.init))
  }

  public var body: some View {
    MainScreen(store: self.store.scope(state: \.main, action: AppAction.main))
      .redacted(reason: self.viewStore.isMainWindowRedacted ? .placeholder : [])
      .frame(minWidth: 1280, minHeight: 720)
      .onAppear { self.viewStore.send(.onAppear) }
      .sheet(
        isPresented:
        self.viewStore.binding(get: \.isAuthScreenPresented, send: .dismissAuthenticationSheet)
      ) {
        IfLetStore(self.store.scope(state: \.auth, action: AppAction.auth)) { store in
          AuthenticationScreen(store: store)
        }
      }
  }
}

private extension AppView.ViewState {
  init(_ appState: AppState) {
    self.isMainWindowRedacted = appState.isMainWindowRedacted
    self.isAuthScreenPresented = appState.auth != nil
  }
}
