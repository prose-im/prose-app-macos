//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import ProseCoreTCA

extension Reducer where Action: Equatable {
  func sendChatState(
    _ chatState: ProseCoreTCA.ChatState,
    with sendChatState: @escaping (State, Environment)
      -> ((ProseCoreTCA.ChatState) -> Effect<Void, Never>),
    when triggeringAction: Action
  ) -> Self {
    self.combined(with: Reducer { state, action, environment in
      switch action {
      case triggeringAction:
        return sendChatState(state, environment)(chatState)
          .fireAndForget()
      default:
        return .none
      }
    })
  }
}
