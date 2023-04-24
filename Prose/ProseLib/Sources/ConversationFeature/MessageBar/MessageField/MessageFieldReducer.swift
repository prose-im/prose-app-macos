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
    var isFocused = false
    var message = ""

    var isComposing = false

    var isSendButtonEnabled: Bool {
      !self.trimmedMessage.isEmpty
    }

    var trimmedMessage: String {
      self.message.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public init() {}
  }

  public enum Action: Equatable {
    case onAppear
    case onDisappear

    case messageChanged(String)
    case focusChanged(Bool)
    case composeDelayExpired

    case sendButtonTapped
  }

  private enum EffectToken: Hashable, CaseIterable {
    case composeDelay
  }

  @Dependency(\.continuousClock) var clock

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      func updateComposingState() -> EffectTask<Action> {
        state.isComposing = state.isFocused && !state.message.isEmpty

        if !state.isComposing {
          return .cancel(id: EffectToken.composeDelay)
        }

        return .task {
          try await withTaskCancellation(id: EffectToken.composeDelay, cancelInFlight: true) {
            try await self.clock.sleep(for: .composeDelay)
            return .composeDelayExpired
          }
        }
      }

      switch action {
      case .onDisappear:
        return .cancel(token: EffectToken.self)

      case let .focusChanged(isFocused):
        state.isFocused = isFocused
        return updateComposingState()

      case let .messageChanged(message):
        state.message = message
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
