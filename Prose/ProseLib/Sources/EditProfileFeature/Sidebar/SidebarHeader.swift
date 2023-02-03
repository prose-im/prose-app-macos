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

private let l10n = L10n.EditProfile.Sidebar.Header.self

// MARK: - View

struct SidebarHeader: View {
  typealias ViewState = SessionState<SidebarHeaderState>
  typealias ViewAction = SidebarHeaderAction

  let store: Store<ViewState, ViewAction>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        Button { viewStore.send(.editAvatarTapped) } label: { Self.avatarView(viewStore: viewStore)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(l10n.ChangeAvatarAction.axLabel)
        .accessibilityHint(l10n.ChangeAvatarAction.axHint)
        VStack {
          Text(verbatim: viewStore.currentUser.name)
            .font(.headline)
          Text(verbatim: viewStore.currentUser.jid.jidString)
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
          l10n.ProfileDetails
            .axLabel(viewStore.currentUser.name, viewStore.currentUser.jid.jidString)
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
  static func avatarView(viewStore: ViewStore<ViewState, ViewAction>) -> some View {
    let avatar = Avatar(
      viewStore.currentUser.avatar.map(AvatarImage.init) ?? .placeholder,
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

    let viewStore: ViewStore<ViewState, ViewAction>

    func performDrop(info: DropInfo) -> Bool {
      guard let imageProvider = info.itemProviders(for: Self.supportedUTIs).first else {
        return false
      }
      self.viewStore.send(.onDropAvatarImage(imageProvider))
      return true
    }
  }
}

enum SidebarHeaderEffectToken: Hashable, CaseIterable {
  case loadDroppedImage
  case uploadAvatarImage
}

// MARK: - The Composable Architecture

// MARK: Reducer

let sidebarHeaderReducer = AnyReducer<
  SessionState<SidebarHeaderState>,
  SidebarHeaderAction,
  SidebarHeaderEnvironment
> { state, action, environment in
  switch action {
  case .onDisappear:
    return .cancel(token: SidebarHeaderEffectToken.self)

  case let .onHoverAvatar(isHovered):
    state.isAvatarHovered = isHovered
    return .none

  case let .onDropAvatarImage(provider):
    return provider.prose_systemImagePublisher()
      .tryMap { image -> CGImage in
        guard let image = image.cgImage else {
          throw ItemProviderError.invalidItemData
        }
        return image
      }
      .receive(on: environment.mainQueue)
      .mapError(EquatableError.init)
      .catchToEffect()
      .map(SidebarHeaderAction.loadDroppedImageResult)
      .cancellable(id: SidebarHeaderEffectToken.loadDroppedImage)

  case let .loadDroppedImageResult(.success(image)):
    return environment.proseClient.setAvatarImage(image)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(SidebarHeaderAction.uploadAvatarImageResult)
      .cancellable(id: SidebarHeaderEffectToken.uploadAvatarImage)

  case let .loadDroppedImageResult(.failure(error)):
    logger.error("Could not load dropped image. \(error.localizedDescription, privacy: .public)")
    return .none

  case .uploadAvatarImageResult(.success):
    logger.info("Successfully uploaded avatar image")
    return .none

  case let .uploadAvatarImageResult(.failure(error)):
    logger.error("Could not upload avatar image. \(error.localizedDescription, privacy: .public)")
    return .none

  case .editAvatarTapped:
    logger.trace("Edit profile picture tapped")
    return .none

  case .binding:
    return .none
  }
}.binding()

struct SidebarHeaderEnvironment {
  var proseClient: ProseClient
  var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(proseClient: ProseClient, mainQueue: AnySchedulerOf<DispatchQueue>) {
    self.proseClient = proseClient
    self.mainQueue = mainQueue
  }
}

// MARK: State

public struct SidebarHeaderState: Equatable {
  let avatar: AvatarImage
  let fullName: String
  let jid: String

  @BindingState var isAvatarHovered: Bool

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
  case onDropAvatarImage(NSItemProvider)
  case loadDroppedImageResult(Result<CGImage, EquatableError>)
  case uploadAvatarImageResult(Result<None, EquatableError>)
  case binding(BindingAction<SessionState<SidebarHeaderState>>)
  case onDisappear
}

// MARK: - Previews

#if DEBUG
  struct SidebarHeader_Previews: PreviewProvider {
    static var previews: some View {
      Self.preview(state: .init())
      Self.preview(state: .init(isAvatarHovered: true))
        .previewDisplayName("Avatar hovered")
    }

    static func preview(state _: SidebarHeaderState) -> some View {
      SidebarHeader(store: Store(
        initialState: .mock(SidebarHeaderState()),
        reducer: sidebarHeaderReducer,
        environment: SidebarHeaderEnvironment(proseClient: .noop, mainQueue: .main)
      ))
      .padding()
    }
  }
#endif
