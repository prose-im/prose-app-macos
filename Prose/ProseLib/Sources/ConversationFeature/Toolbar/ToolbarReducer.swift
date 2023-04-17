//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture

public struct ToolbarReducer: ReducerProtocol {
  public typealias State = ChatSessionState<ToolbarState>

  public struct ToolbarState: Equatable {
    #warning("FIXME")
    // let user: User? = .placeholder
    @BindingState var isShowingInfo = false
  }

  public enum Action: Equatable, BindableAction {
    case startVideoCallTapped
    case binding(BindingAction<ChatSessionState<ToolbarState>>)
  }

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce { _, action in
      switch action {
      case .startVideoCallTapped:
        logger.info("Start video call tapped")
        return .none

      case .binding:
        return .none
      }
    }
  }
}
