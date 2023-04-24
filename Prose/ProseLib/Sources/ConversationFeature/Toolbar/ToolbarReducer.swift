//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import ComposableArchitecture

public struct ToolbarReducer: ReducerProtocol {
  public typealias State = ChatSessionState<ToolbarState>

  public struct ToolbarState: Equatable {
    var isShowingInfo = false
  }

  public enum Action: Equatable {
    case startVideoCallTapped
    case toggleInfoButtonTapped
  }

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .startVideoCallTapped:
        logger.info("Start video call tapped")
        return .none

      case .toggleInfoButtonTapped:
        state.isShowingInfo.toggle()
        return .none
      }
    }
  }
}

extension ToolbarReducer.State {
  var contact: Contact {
    if let contact = self.userInfos[self.chatId] {
      return contact
    }
    return Contact(
      jid: self.chatId,
      name: self.chatId.rawValue,
      avatar: nil,
      availability: .unavailable,
      status: nil,
      groups: []
    )
  }
}
