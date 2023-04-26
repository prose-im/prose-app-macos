//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import SwiftUI

public struct AuthenticationScreen: View {
  struct ViewState: Equatable {
    var emoji: String
    var title: String
    var subtitle: String
  }

  private let store: StoreOf<AuthenticationReducer>
  @ObservedObject var viewStore: ViewStore<ViewState, AuthenticationReducer.Action>

  public init(store: StoreOf<AuthenticationReducer>) {
    self.store = store
    self.viewStore = ViewStore(store.scope(state: ViewState.init))
  }

  public var body: some View {
    VStack(spacing: 32) {
      VStack(spacing: 4) {
        Text(self.viewStore.emoji)
          .font(.system(size: 64))
          .padding(.bottom, 20)
        Text(self.viewStore.title)
          .font(.system(size: 24, weight: .bold))
        Text(self.viewStore.subtitle)
          .foregroundColor(.secondary)
          .font(.system(size: 16))
      }

      SwitchStore(self.store.scope(state: \.route)) {
        CaseLet(
          state: /AuthenticationReducer.Route.basicAuth,
          action: AuthenticationReducer.Action.basicAuth,
          then: BasicAuthView.init(store:)
        )
        CaseLet(
          state: /AuthenticationReducer.Route.profile,
          action: AuthenticationReducer.Action.profile,
          then: ProfileView.init
        )
      }
    }
    .multilineTextAlignment(.center)
    .controlSize(.large)
    .textFieldStyle(.roundedBorder)
    .buttonBorderShape(.roundedRectangle)
    .padding(.horizontal, 48)
    .padding(.vertical, 24)
    .frame(minWidth: 400)
  }
}

extension AuthenticationScreen.ViewState {
  init(_ state: AuthenticationReducer.State) {
    switch state.route {
    case .basicAuth:
      self.emoji = "👋"
      self.title = L10n.Authentication.BasicAuth.Header.title
      self.subtitle = L10n.Authentication.BasicAuth.Header.subtitle

    case .profile:
      self.emoji = "👋"
      self.title = L10n.Authentication.Profile.Header.title
      self.subtitle = L10n.Authentication.Profile.Header.subtitle
    }
  }
}
