//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import ProseCoreTCA
import SwiftUI

private let l10n = L10n.Content.EditMessage.self

// MARK: - View

struct EditMessageView: View {
  let store: Store<ChatSessionState<EditMessageState>, EditMessageAction>
  var body: some View {
    VStack(alignment: .leading) {
      Text(l10n.title)
        .font(.title2.bold())
      MessageField(store: self.store.scope(
        state: \.messageField,
        action: EditMessageAction.messageField
      ), cornerRadius: 8)
    }
    .safeAreaInset(edge: .bottom, spacing: 12) {
      HStack {
        Group {
          MessageFormattingButton(store: self.store.scope(
            state: \.formatting,
            action: EditMessageAction.formatting
          ))
          MessageEmojisButton(store: self.store.scope(
            state: \.emojis,
            action: EditMessageAction.emojis
          ))
        }
        .buttonStyle(.plain)
        .font(MessageBar.buttonsFont)
        Spacer()
        WithViewStore(self.store.scope(state: \.childState.isConfirmButtonDisabled)) { viewStore in
          Button(l10n.CancelAction.title, role: .cancel) { viewStore.send(.cancelTapped) }
            .buttonStyle(.bordered)
          Button(l10n.ConfirmAction.title) { viewStore.send(.confirmTapped) }
            .buttonStyle(.borderedProminent)
            .disabled(viewStore.state)
        }
      }
      .controlSize(.large)
    }
    .padding()
    .frame(width: 500)
    .frame(minHeight: 200)
  }
}

// MARK: Reducer

public let editMessageReducer: AnyReducer<
  ChatSessionState<EditMessageState>,
  EditMessageAction,
  ConversationEnvironment
> = AnyReducer.combine([
  messageFieldReducer.pullback(
    state: \.messageField,
    action: CasePath(EditMessageAction.messageField),
    environment: { $0 }
  ),
  messageFormattingReducer.pullback(
    state: \.formatting,
    action: CasePath(EditMessageAction.formatting),
    environment: { _ in () }
  ),
  messageEmojisReducer.pullback(
    state: \.emojis,
    action: CasePath(EditMessageAction.emojis),
    environment: { _ in () }
  ),
  AnyReducer { state, action, _ in
    switch action {
    case .confirmTapped:
      if !state.childState.isConfirmButtonDisabled {
        return EffectTask(value: .saveEdit(state.childState.messageId, state.messageField.message))
      } else {
        return .none
      }

    case let .emojis(.insert(reaction)):
      state.messageField.message.append(contentsOf: reaction.rawValue)
      return .none

    case .cancelTapped, .saveEdit, .messageField, .formatting, .emojis:
      return .none
    }
  },
])

// MARK: State

public struct EditMessageState: Equatable {
  let messageId: Message.ID
  var messageField: MessageFieldState
  var formatting: MessageFormattingState = .init()
  var emojis: MessageEmojisState = .init()

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
    self.messageField = .init(
      placeholder: message,
      isMultiline: true,
      hideSendButton: true,
      message: message
    )
    self.originalMessageHash = message.hashValue
  }
}

// MARK: Actions

public enum EditMessageAction: Equatable {
  case cancelTapped, confirmTapped
  case saveEdit(Message.ID, String)
  case messageField(MessageFieldAction)
  case formatting(MessageFormattingAction)
  case emojis(MessageEmojisAction)
}

#if DEBUG

  // MARK: - Previews

  struct EditMessageView_Previews: PreviewProvider {
    static var previews: some View {
      Self.preview(state: EditMessageState(
        messageId: "message-id",
        message: "The message being edited"
      ))
      Text("Run the preview")
        .frame(width: 800, height: 500)
        .sheet(isPresented: .constant(true)) {
          Self.preview(state: EditMessageState(
            messageId: "message-id",
            message: "The message being edited"
          ))
        }
        .previewDisplayName("EditMessageView in a sheet")
    }

    static func preview(state: EditMessageState) -> some View {
      EditMessageView(store: Store(
        initialState: .mock(state),
        reducer: editMessageReducer,
        environment: ConversationEnvironment(
          proseClient: .noop,
          pasteboard: .live(),
          mainQueue: .main
        )
      ))
    }
  }
#endif
