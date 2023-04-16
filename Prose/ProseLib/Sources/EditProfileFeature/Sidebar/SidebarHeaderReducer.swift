//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import CoreGraphics
import Foundation
import ProseCoreTCA
import ProseUI
import Toolbox

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
    case loadDroppedImageResult(TaskResult<CGImage>)
    case uploadAvatarImageResult(TaskResult<None>)
    case binding(BindingAction<SessionState<SidebarHeaderState>>)
    case onDisappear
  }

  private enum EffectToken: Hashable, CaseIterable {
    case loadDroppedImage
    case uploadAvatarImage
  }

  public init() {}

  @Dependency(\.mainQueue) var mainQueue

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
            var iter = provider.prose_systemImagePublisher().values.makeAsyncIterator()
            guard let image = try await iter.next()?.cgImage else {
              throw ItemProviderError.invalidItemData
            }
            return image
          })
        }.cancellable(id: EffectToken.loadDroppedImage)

      case let .loadDroppedImageResult(.success(image)):
        #warning("FIXME")
//        return environment.proseClient.setAvatarImage(image)
//          .receive(on: self.mainQueue)
//          .catchToEffect(Action.uploadAvatarImageResult)
//          .cancellable(id: EffectToken.uploadAvatarImage)
        return .none

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
