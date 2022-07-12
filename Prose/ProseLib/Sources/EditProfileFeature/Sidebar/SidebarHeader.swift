//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import ProseUI
import SwiftUI

private let l10n = L10n.EditProfile.Sidebar.Header.self

// MARK: - View

struct SidebarHeader: View {
  typealias ViewState = SidebarHeaderState
  typealias ViewAction = SidebarHeaderAction

  let store: Store<ViewState, ViewAction>

  var body: some View {
    VStack {
      WithViewStore(self.store) { viewStore in
        Button { viewStore.send(.editAvatarTapped) } label: { Self.avatarView(viewStore: viewStore)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(l10n.ChangeAvatarAction.axLabel)
        .accessibilityHint(l10n.ChangeAvatarAction.axHint)
        VStack {
          Text(verbatim: viewStore.fullName)
            .font(.headline)
          Text(verbatim: viewStore.jid)
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(l10n.ProfileDetails.axLabel(viewStore.fullName, viewStore.jid))
        // Higher priority on the profile label
        .accessibilitySortPriority(1)
      }
    }
    .multilineTextAlignment(.center)
  }

  @ViewBuilder
  static func avatarView(viewStore: ViewStore<ViewState, ViewAction>) -> some View {
    let avatar = Avatar(viewStore.avatar, size: 80, cornerRadius: 12)
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
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let sidebarHeaderReducer = Reducer<
  SidebarHeaderState,
  SidebarHeaderAction,
  Void
> { state, action, _ in
  switch action {
  case let .onHoverAvatar(isHovered):
    state.isAvatarHovered = isHovered
    return .none

  case .editAvatarTapped:
    logger.trace("Edit profile picture tapped")
    return .none

  case .binding:
    return .none
  }
}.binding()

// MARK: State

public struct SidebarHeaderState: Equatable {
  let avatar: AvatarImage
  let fullName: String
  let jid: String

  @BindableState var isAvatarHovered: Bool

  public init(
    avatar: AvatarImage = .placeholder,
    fullName: String = "Baptiste Jamin",
    jid: String = "baptiste@crisp.chat",
    isAvatarHovered: Bool = false
  ) {
    self.avatar = avatar
    self.fullName = fullName
    self.jid = jid
    self.isAvatarHovered = isAvatarHovered
  }
}

// MARK: Actions

public enum SidebarHeaderAction: Equatable, BindableAction {
  case editAvatarTapped
  case onHoverAvatar(Bool)
  case binding(BindingAction<SidebarHeaderState>)
}

// MARK: - Previews

struct SidebarHeader_Previews: PreviewProvider {
  static var previews: some View {
    Self.preview(state: .init())
    Self.preview(state: .init(isAvatarHovered: true))
      .previewDisplayName("Avatar hovered")
  }

  static func preview(state _: SidebarHeaderState) -> some View {
    SidebarHeader(store: Store(
      initialState: SidebarHeaderState(),
      reducer: sidebarHeaderReducer,
      environment: ()
    ))
    .padding()
  }
}
