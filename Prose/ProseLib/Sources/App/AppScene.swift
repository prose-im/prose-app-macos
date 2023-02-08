//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AuthenticationFeature
import ComposableArchitecture
import MainScreenFeature
import SettingsFeature
import SwiftUI

public struct AppScene: Scene {
  private let store: StoreOf<App>

  public init() {
    self.store = Store(initialState: .init(), reducer: App())
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
    var isMainScreenRedacted: Bool
    var isAuthScreenPresented: Bool
  }

  private let store: StoreOf<App>
  @ObservedObject private var viewStore: ViewStore<ViewState, App.Action>

  init(store: StoreOf<App>) {
    self.store = store
    self.viewStore = ViewStore(store.scope(state: ViewState.init))
  }

  public var body: some View {
    MainScreenView(store: self.store.scope(state: \.main, action: App.Action.main))
      .redacted(reason: self.viewStore.isMainScreenRedacted ? .placeholder : [])
      .frame(minWidth: 1280, minHeight: 720)
      .onAppear { self.viewStore.send(.onAppear) }
      .sheet(
        isPresented:
        self.viewStore.binding(get: \.isAuthScreenPresented, send: .dismissAuthenticationSheet)
      ) {
        IfLetStore(self.store.scope(state: \.auth, action: App.Action.auth)) { store in
          AuthenticationScreen(store: store)
        }
      }
  }
}

private extension AppView.ViewState {
  init(_ appState: App.State) {
    self.isMainScreenRedacted = appState.isMainScreenRedacted
    self.isAuthScreenPresented = appState.auth != nil
  }
}
