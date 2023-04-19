//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import ComposableArchitecture
import Foundation
import TCAUtils

extension Duration {
  static let composeDelay: Self = .seconds(30)
}

public struct MessageFieldReducer: ReducerProtocol {
  public typealias State = ChatSessionState<MessageFieldState>

  public struct MessageFieldState: Equatable {
    @BindingState var isFocused = false
    @BindingState var message = ""

    var isComposing = false

    var isSendButtonEnabled: Bool {
      !self.trimmedMessage.isEmpty
    }

    var trimmedMessage: String {
      self.message.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onAppear
    case onDisappear

    case binding(BindingAction<State>)
    case composeDelayExpired

    case sendButtonTapped
  }

  private enum EffectToken: Hashable, CaseIterable {
    case composeDelay
  }

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce { state, action in
      func updateComposingState() -> EffectTask<Action> {
        state.isComposing = state.isFocused && !state.message.isEmpty

        if !state.isComposing {
          return .cancel(id: EffectToken.composeDelay)
        }

        return .task {
          try await Task.sleep(for: .composeDelay)
          return .composeDelayExpired
        }.cancellable(id: EffectToken.composeDelay, cancelInFlight: true)
      }

      switch action {
      case .onDisappear:
        return .cancel(token: EffectToken.self)

      case .binding:
        return updateComposingState()

      case .sendButtonTapped:
        state.isComposing = false
        return .cancel(id: EffectToken.composeDelay)

      case .composeDelayExpired:
        state.isComposing = false
        return .none

      case .onAppear:
        return .none
      }
    }
  }
}
