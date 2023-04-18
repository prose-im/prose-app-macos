//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import ComposableArchitecture
import Foundation

public struct MessageFieldReducer: ReducerProtocol {
  public typealias State = ChatSessionState<MessageFieldState>

  public struct MessageFieldState: Equatable {
    @BindingState var isFocused = false
    @BindingState var message = ""

    var isSendButtonEnabled: Bool {
      !self.trimmedMessage.isEmpty
    }

    var trimmedMessage: String {
      self.message.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case sendButtonTapped
    case binding(BindingAction<State>)
  }

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
  }
}
