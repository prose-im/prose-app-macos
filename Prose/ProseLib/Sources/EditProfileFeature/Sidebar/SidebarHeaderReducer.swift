//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import CoreGraphics
import Foundation
import ProseCore
import ProseUI
import TCAUtils
import Toolbox
import UniformTypeIdentifiers

public struct SidebarHeaderReducer: ReducerProtocol {
  public typealias State = SessionState<SidebarHeaderState>

  public struct SidebarHeaderState: Equatable {
    @BindingState var isAvatarHovered = false

    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case editAvatarTapped
    case onHoverAvatar(Bool)
    case onDropAvatarImage(NSItemProvider)
    case loadDroppedImageResult(TaskResult<URL?>)
    case uploadAvatarImageResult(TaskResult<None>)
    case binding(BindingAction<SessionState<SidebarHeaderState>>)
    case onDisappear
  }

  private enum EffectToken: Hashable, CaseIterable {
    case loadDroppedImage
    case uploadAvatarImage
  }

  public init() {}

  @Dependency(\.accountsClient) var accounts

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    self.core
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .onDisappear:
        return .cancel(token: EffectToken.self)

      case let .onHoverAvatar(isHovered):
        state.isAvatarHovered = isHovered
        return .none

      case let .onDropAvatarImage(provider):
        return .task {
          await .loadDroppedImageResult(TaskResult {
            guard
              let image = try await provider.prose_loadImage(),
              let jpegData = image.jpegData(compressionQuality: 0.8)
            else {
              return nil
            }
            let url = URL.temporaryDirectory.appending(component: "\(UUID().uuidString).jpg")
            try jpegData.write(to: url)
            return url
          })
        }.cancellable(id: EffectToken.loadDroppedImage)

      case let .loadDroppedImageResult(.success(url)):
        guard let url else {
          logger.info("The dropped file wasn't an image.")
          return .none
        }
        return .task { [currentUser = state.currentUser] in
          await .uploadAvatarImageResult(TaskResult {
            try await self.accounts.client(currentUser).saveAvatar(url)
          })
        }

      case let .loadDroppedImageResult(.failure(error)):
        logger
          .error("Could not load dropped image. \(error.localizedDescription, privacy: .public)")
        return .none

      case .uploadAvatarImageResult(.success):
        logger.info("Successfully uploaded avatar image")
        return .none

      case let .uploadAvatarImageResult(.failure(error)):
        logger
          .error("Could not upload avatar image. \(error.localizedDescription, privacy: .public)")
        return .none

      case .editAvatarTapped:
        logger.trace("Edit profile picture tapped")
        return .none

      case .binding:
        return .none
      }
    }
  }
}
