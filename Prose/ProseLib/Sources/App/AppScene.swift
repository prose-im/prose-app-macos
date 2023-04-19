//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AuthenticationFeature
import ComposableArchitecture
import MainScreenFeature
import SettingsFeature
import SwiftUI

public struct AppScene: Scene {
  private let store: StoreOf<AppReducer>

  public init() {
    self.store = Store(initialState: .init(), reducer: AppReducer())
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

struct AppView: View {
  struct ViewState: Equatable {
    var isAuthScreenPresented: Bool
  }

  private let store: StoreOf<AppReducer>
  @ObservedObject private var viewStore: ViewStore<ViewState, AppReducer.Action>

  init(store: StoreOf<AppReducer>) {
    self.store = store
    self.viewStore = ViewStore(store.scope(state: ViewState.init))
  }

  public var body: some View {
    IfLetStore(self.store.scope(state: \.main, action: AppReducer.Action.main)) { store in
      MainScreenView(store: store)
    } else: {
      Color.systemBackground
    }
    .frame(minWidth: 1280, minHeight: 720)
    .onAppear { self.viewStore.send(.onAppear) }
    .sheet(isPresented: self.viewStore.binding(
      get: \.isAuthScreenPresented,
      send: .dismissAuthenticationSheet
    )) {
      IfLetStore(self.store.scope(state: \.auth, action: AppReducer.Action.auth)) { store in
        AuthenticationScreen(store: store)
      }
    }
  }
}

private extension AppView.ViewState {
  init(_ appState: AppReducer.State) {
    self.isAuthScreenPresented = appState.auth != nil
  }
}

private extension Color {
  #if canImport(UIKit)
    static let systemBackground = Color(uiColor: .systemBackground)
  #endif
  #if canImport(AppKit)
    static let systemBackground = Color(nsColor: .windowBackgroundColor)
  #endif
}
