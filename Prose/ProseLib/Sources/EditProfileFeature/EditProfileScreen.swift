//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import SwiftUI

public struct EditProfileScreen: View {
  static let minContentWidth: CGFloat = 480

  let store: StoreOf<EditProfileReducer>

  public init(store: StoreOf<EditProfileReducer>) {
    self.store = store
  }

  public var body: some View {
    NavigationSplitView(
      sidebar: {
        Sidebar(
          store: self.store
            .scope(state: \.sidebar, action: EditProfileReducer.Action.sidebar)
        )
      },
      detail: {
        self.detailView()
          .frame(minWidth: Self.minContentWidth, minHeight: 512)
          .safeAreaInset(edge: .bottom, alignment: .trailing) {
            HStack {
              WithViewStore(
                self.store
                  .scope(state: \.childState.isSaveProfileButtonDisabled)
              ) { viewStore in
                Button(L10n.EditProfile.CancelAction.label) { viewStore.send(.cancelTapped) }
                Button(L10n.EditProfile.SaveProfileAction.label) {
                  viewStore.send(.saveProfileTapped)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewStore.state)
              }
            }
            .controlSize(.large)
            .padding(4)
            .background {
              RoundedRectangle(cornerRadius: 8)
                .fill(Material.regular)
            }
            .padding([.horizontal, .bottom])
            // Make sure accessibility frame isn't inset by the window's rounded corners
            .contentShape(Rectangle())
            // Make footer have a higher priority, to be accessible over the scroll view
            .accessibilitySortPriority(1)
          }
      }
    )
    // NOTE: +1 for the separator width…
    .frame(minWidth: Self.minContentWidth + Sidebar.minWidth + 1)
  }

  func detailView() -> some View {
    IfLetStore(self.store.scope(state: \.route)) { store in
      SwitchStore(store) {
        CaseLet(
          state: CasePath(EditProfileReducer.Route.identity).extract,
          action: EditProfileReducer.Action.identity,
          then: IdentityView.init(store:)
        )
        CaseLet(
          state: CasePath(EditProfileReducer.Route.authentication).extract,
          action: EditProfileReducer.Action.authentication,
          then: AuthenticationView.init(store:)
        )
        CaseLet(
          state: CasePath(EditProfileReducer.Route.profile).extract,
          action: EditProfileReducer.Action.profile,
          then: ProfileView.init(store:)
        )
        CaseLet(
          state: CasePath(EditProfileReducer.Route.encryption).extract,
          action: EditProfileReducer.Action.encryption,
          then: EncryptionView.init(store:)
        )
      }
    }
  }
}
