//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppDomain
import ComposableArchitecture
import ProseUI

public struct EditMessageReducer: ReducerProtocol {
  public typealias State = ChatSessionState<EditMessageState>

  public struct EditMessageState: Equatable {
    let messageId: Message.ID
    var messageField = MessageFieldReducer.MessageFieldState()
    var emojiPicker: ReactionPickerReducer.State?

    var isMessageEdited = false

    var isConfirmButtonEnabled: Bool {
      self.messageField.isSendButtonEnabled && self.isMessageEdited
    }

    public init(messageId: Message.ID, message: String) {
      self.messageId = messageId
      self.messageField.message = message
    }
  }

  public enum Action: Equatable {
    case cancelTapped
    case confirmTapped

    case emojiButtonTapped
    case emojiPickerDismissed

    case saveEdit(Message.ID, String)
    case messageField(MessageFieldReducer.Action)
    case emojiPicker(ReactionPickerReducer.Action)
  }

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    Scope(state: \.messageField, action: /Action.messageField) {
      MessageFieldReducer()
    }.onChange(of: \.messageField.childState.message) { _, state, _ in
      state.isMessageEdited = true
      return .none
    }
    self.core
      .ifLet(\.emojiPicker, action: /Action.emojiPicker) {
        ReactionPickerReducer()
      }
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case let .emojiPicker(.select(emoji)):
        state.emojiPicker = nil
        state.messageField.message.append(contentsOf: emoji)
        return .none

      case .emojiButtonTapped:
        state.emojiPicker = .init()
        return .none

      case .emojiPickerDismissed:
        state.emojiPicker = nil
        return .none

      case .confirmTapped, .cancelTapped, .saveEdit, .messageField, .emojiPicker:
        return .none
      }
    }
  }
}

extension EditMessageReducer.State {
  var messageField: MessageFieldReducer.State {
    get { self.get(\.messageField) }
    set { self.set(\.messageField, newValue) }
  }
}
