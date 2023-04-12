//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import ProseBackend

public struct EditMessageReducer: ReducerProtocol {
  public typealias State = ChatSessionState<EditMessageState>

  public struct EditMessageState: Equatable {
    let messageId: Message.ID
    var messageField = MessageFieldReducer.State()
    // var formatting: MessageFormattingState = .init()
    // var emojis: MessageEmojisState = .init()

    let originalMessageHash: Int
    var isConfirmButtonDisabled: Bool {
      self.messageField.message.isEmpty
        || self.messageField.message.hashValue == self.originalMessageHash
    }

    public init(
      messageId: Message.ID,
      message: String
    ) {
      self.messageId = messageId
      self.originalMessageHash = message.hashValue
    }
  }

  public enum Action: Equatable {
    case cancelTapped
    case confirmTapped
    case saveEdit(Message.ID, String)
    case messageField(MessageFieldReducer.Action)
    // case formatting(MessageFormattingAction)
    // case emojis(MessageEmojisAction)
  }

  public init() {}

  @Dependency(\.mainQueue) var mainQueue

  public var body: some ReducerProtocol<State, Action> {
    #warning("FIXME")
//  messageFieldReducer.pullback(
//    state: \.messageField,
//    action: CasePath(EditMessageAction.messageField),
//    environment: { $0 }
//  ),
//  messageFormattingReducer.pullback(
//    state: \.formatting,
//    action: CasePath(EditMessageAction.formatting),
//    environment: { _ in () }
//  ),
//  messageEmojisReducer.pullback(
//    state: \.emojis,
//    action: CasePath(EditMessageAction.emojis),
//    environment: { _ in () }
//  ),

    self.core
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .confirmTapped:
        if !state.childState.isConfirmButtonDisabled {
          return EffectTask(value: .saveEdit(
            state.childState.messageId,
            state.messageField.message
          ))
        } else {
          return .none
        }

        #warning("FIXME")
//      case let .emojis(.insert(reaction)):
//        state.messageField.message.append(contentsOf: reaction.rawValue)
//        return .none

      case .cancelTapped, .saveEdit, .messageField:
        return .none
      }
    }
  }
}
