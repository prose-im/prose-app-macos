//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import ProseCoreTCA
import SwiftUI

// MARK: - View

struct EditMessageView: View {
  let store: Store<EditMessageState, EditMessageAction>
  var body: some View {
    VStack(alignment: .leading) {
      Text("Edit your message")
        .font(.title2.bold())
      MessageBarTextField(store: self.store.scope(
        state: \.textField,
        action: EditMessageAction.textField
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
        WithViewStore(self.store.scope(state: \.isConfirmButtonDisabled)) { viewStore in
          Button("Cancel", role: .cancel) { viewStore.send(.cancelTapped) }
            .buttonStyle(.bordered)
          Button("Confirm") { viewStore.send(.confirmTapped) }
            .buttonStyle(.borderedProminent)
            .disabled(viewStore.state)
        }
      }
      .controlSize(.large)
    }
    .padding()
    .frame(width: 500, height: 200)
  }
}

// MARK: Reducer

public let editMessageReducer: Reducer<
  EditMessageState,
  EditMessageAction,
  ConversationEnvironment
> = Reducer.combine([
  messageBarTextFieldReducer.pullback(
    state: \EditMessageState.textField,
    action: CasePath(EditMessageAction.textField),
    environment: { $0 }
  ),
  messageFormattingReducer.pullback(
    state: \EditMessageState.formatting,
    action: CasePath(EditMessageAction.formatting),
    environment: { _ in () }
  ),
  messageEmojisReducer.pullback(
    state: \EditMessageState.emojis,
    action: CasePath(EditMessageAction.emojis),
    environment: { _ in () }
  ),
  Reducer { state, action, _ in
    switch action {
    case .confirmTapped:
      if !state.isConfirmButtonDisabled {
        return Effect(value: .saveEdit(state.messageId, state.textField.message))
      } else {
        return .none
      }

    case let .emojis(.insert(reaction)):
      state.textField.message.append(contentsOf: reaction.rawValue)
      return .none

    case .cancelTapped, .saveEdit, .textField, .formatting, .emojis:
      return .none
    }
  },
])

// MARK: State

public struct EditMessageState: Equatable {
  let messageId: Message.ID
  var textField: MessageBarTextFieldState
  var formatting: MessageFormattingState = .init()
  var emojis: MessageEmojisState = .init()

  let originalMessageHash: Int
  var isConfirmButtonDisabled: Bool {
    self.textField.message.isEmpty
      || self.textField.message.hashValue == self.originalMessageHash
  }

  public init(
    chatId: JID,
    messageId: Message.ID,
    message: String
  ) {
    self.messageId = messageId
    self.textField = .init(
      chatId: chatId,
      placeholder: message,
      isEditingAMessage: true,
      message: message
    )
    self.originalMessageHash = message.hashValue
  }
}

// MARK: Actions

public enum EditMessageAction: Equatable {
  case cancelTapped, confirmTapped
  case saveEdit(Message.ID, String)
  case textField(MessageBarTextFieldAction)
  case formatting(MessageFormattingAction)
  case emojis(MessageEmojisAction)
}

#if DEBUG

  // MARK: - Previews

  struct EditMessageView_Previews: PreviewProvider {
    static var previews: some View {
      Self.preview(state: EditMessageState(
        chatId: "preview@prose.org",
        messageId: "message-id",
        message: "The message being edited"
      ))
      Text("Run the preview")
        .frame(width: 800, height: 500)
        .sheet(isPresented: .constant(true)) {
          Self.preview(state: EditMessageState(
            chatId: "preview@prose.org",
            messageId: "message-id",
            message: "The message being edited"
          ))
        }
        .previewDisplayName("EditMessageView in a sheet")
    }

    static func preview(state: EditMessageState) -> some View {
      EditMessageView(store: Store(
        initialState: state,
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
