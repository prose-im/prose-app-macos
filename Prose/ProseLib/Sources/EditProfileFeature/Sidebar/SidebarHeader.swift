//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import ProseCoreTCA
import ProseUI
import SwiftUI
import Toolbox
import UniformTypeIdentifiers

struct SidebarHeader: View {
  let store: StoreOf<SidebarHeaderReducer>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        Button { viewStore.send(.editAvatarTapped) } label: { Self.avatarView(viewStore: viewStore)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.EditProfile.Sidebar.Header.ChangeAvatarAction.axLabel)
        .accessibilityHint(L10n.EditProfile.Sidebar.Header.ChangeAvatarAction.axHint)
        VStack {
          Text(verbatim: viewStore.selectedAccount.username)
            .font(.headline)
          Text(verbatim: viewStore.currentUser.rawValue)
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
          L10n.EditProfile.Sidebar.Header.ProfileDetails
            .axLabel(viewStore.selectedAccount.username, viewStore.currentUser.rawValue)
        )
        // Higher priority on the profile label
        .accessibilitySortPriority(1)
      }
      .multilineTextAlignment(.center)
      .onDisappear {
        viewStore.send(.onDisappear)
      }
    }
  }

  @ViewBuilder
  static func avatarView(viewStore: ViewStoreOf<SidebarHeaderReducer>) -> some View {
    let avatar = Avatar(
      viewStore.selectedAccount.avatar.map(AvatarImage.init) ?? .placeholder,
      size: 80,
      cornerRadius: 12
    )
    avatar
      .overlay {
        ZStack(alignment: .bottom) {
          Color.black.opacity(0.125)
          Text("edit")
            .font(.callout.bold())
            .foregroundColor(.white)
            .padding(8)
        }
        .clipShape(avatar.shape)
        .opacity(viewStore.isAvatarHovered ? 1 : 0)
      }
      .onHover { viewStore.send(.onHoverAvatar($0)) }
      .onDrop(
        of: AvatarDropDelegate.supportedUTIs,
        delegate: AvatarDropDelegate(viewStore: viewStore)
      )
  }
}

private extension SidebarHeader {
  struct AvatarDropDelegate: DropDelegate {
    static let supportedUTIs: [UTType] = [.png, .jpeg, .image, .fileURL]

    let viewStore: ViewStoreOf<SidebarHeaderReducer>

    func performDrop(info: DropInfo) -> Bool {
      guard let imageProvider = info.itemProviders(for: Self.supportedUTIs).first else {
        return false
      }
      self.viewStore.send(.onDropAvatarImage(imageProvider))
      return true
    }
  }
}
