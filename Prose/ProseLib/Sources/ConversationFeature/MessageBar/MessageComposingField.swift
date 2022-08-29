//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import ProseCoreTCA
import SwiftUI
import TcaHelpers

private let l10n = L10n.Content.MessageBar.self

// MARK: - View

/// A ``MessageField`` with typing/composing logic.
struct MessageComposingField: View {
  typealias State = ChatSessionState<MessageFieldState>
  typealias Action = MessageComposingFieldAction

  @Environment(\.redactionReasons) private var redactionReasons

  @FocusState private var isFocused: Bool

  let store: Store<State, Action>
  private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

  var body: some View {
    MessageField(
      store: self.store.scope(state: \.childState, action: Action.field)
    )
    .onDisappear { self.actions.send(.onDisappear) }
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

enum MessageComposingFieldEffectToken: Hashable, CaseIterable {
  case pauseTyping
}

public extension DispatchQueue.SchedulerTimeType.Stride {
  static let pauseTypingDebounceDuration: Self = .seconds(30)
}

public let messageComposingFieldReducer = Reducer<
  ChatSessionState<MessageFieldState>,
  MessageComposingFieldAction,
  ConversationEnvironment
>.combine(
  messageFieldReducer.pullback(
    state: \.childState,
    action: CasePath(MessageComposingFieldAction.field),
    environment: { $0 }
  )
  .onChange(of: { TextFieldState($0.childState) }) { current, state, _, environment in
    if !current.isFocused || current.message.isEmpty {
      // If the text field is not focused or empty we don't consider the user typing.
      return .merge(
        environment.proseClient
          .sendChatState(state.chatId, .active)
          .fireAndForget(),
        .cancel(id: MessageComposingFieldEffectToken.pauseTyping)
      )
    } else {
      return .merge(
        environment.proseClient
          .sendChatState(state.chatId, .composing)
          .fireAndForget(),
        Effect(value: .setChatState(.paused))
          .delay(for: .pauseTypingDebounceDuration, scheduler: environment.mainQueue)
          .eraseToEffect()
          .cancellable(id: MessageComposingFieldEffectToken.pauseTyping, cancelInFlight: true)
      )
    }
  },
  Reducer { state, action, environment in
    switch action {
    case let .setChatState(chatState):
      return environment.proseClient
        .sendChatState(state.chatId, chatState)
        .fireAndForget()

    case .onDisappear:
      return .cancel(token: MessageComposingFieldEffectToken.self)

    case .field:
      return .none
    }
  }
)

private struct TextFieldState: Equatable {
  var message: String
  var isFocused: Bool

  init(_ state: MessageFieldState) {
    self.message = state.message
    self.isFocused = state.textField.isFocused
  }
}

// MARK: Actions

public enum MessageComposingFieldAction: Equatable {
  case onDisappear
  case setChatState(ProseCoreTCA.ChatState.Kind)
  case field(MessageFieldAction)
}
