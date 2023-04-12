//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture

public struct MessageFieldReducer: ReducerProtocol {
  public struct State: Equatable {
    @BindingState var isFocused = false
    @BindingState var message = ""

    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case sendTapped
    case send(message: String)
    case binding(BindingAction<State>)
  }

  public init() {}

  @Dependency(\.mainQueue) var mainQueue

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .sendTapped where !state.message.isEmpty:
        let content = state.message
        return EffectTask(value: .send(message: state.message))

      case .sendTapped, .send, .binding:
        return .none
      }
    }
  }
}
