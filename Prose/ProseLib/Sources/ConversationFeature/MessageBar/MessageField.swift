//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import ProseCoreTCA
import ProseUI
import SwiftUI

// MARK: - View

struct MessageField: View {
  typealias State = MessageFieldState
  typealias Action = MessageFieldAction

  static let minimumHeight: CGFloat = 32

  @Environment(\.redactionReasons) private var redactionReasons

  let store: Store<State, Action>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      TCATextView(store: self.store.scope(
        state: \.textField,
        action: Action.textField
      ))
      .onSubmit(of: .text) { viewStore.send(.sendTapped) }
      .safeAreaInset(edge: .trailing, alignment: .bottom, spacing: 0) {
        if viewStore.showSendButton {
          Button { viewStore.send(.sendTapped) } label: {
            Image(systemName: "paperplane.circle.fill")
              .font(.system(size: 24))
              .foregroundColor(.accentColor)
              .frame(width: Self.minimumHeight, height: Self.minimumHeight)
          }
          .buttonStyle(.plain)
          .unredacted()
          .disabled(!viewStore.canSendMessage || self.redactionReasons.contains(.placeholder))
        }
      }
    }
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let messageFieldReducer = Reducer<
  MessageFieldState,
  MessageFieldAction,
  ConversationEnvironment
>.combine(
  textViewReducer.pullback(
    state: \MessageFieldState.textField,
    action: CasePath(MessageFieldAction.textField),
    environment: { _ in () }
  ),
  Reducer { state, action, _ in
    switch action {
    case .sendTapped where state.canSendMessage,
         .textField(.keyboardEventReceived(.newline)) where state.canSendMessage:
      let content: String = state.message
      return Effect(value: .send(message: content))

    case .textField(.textDidChange):
      if state.isMultiline {
        state.textField.interceptedEvents.remove(.newline)
      } else {
        state.textField.interceptedEvents.insert(.newline)
      }
      return .none

    case .sendTapped, .send, .textField:
      return .none
    }
  }
)

// MARK: State

public struct MessageFieldState: Equatable {
//  let chatId: JID
  let showSendButton: Bool

  var textField: TCATextViewState

  var canSendMessage: Bool { !self.textField.isEmpty }

  var message: String {
    get { NSAttributedString(self.textField.text).string }
    set { self.textField.setText(to: newValue) }
  }

  var isMultiline: Bool {
    let newlines = CharacterSet.newlines
    return self.message.contains { $0.unicodeScalars.contains(where: newlines.contains) }
  }

  init(
    placeholder: String,
    isMultiline: Bool = false,
    message: String = ""
  ) {
//    self.chatId = chatId
    self.showSendButton = !isMultiline
    self.textField = TCATextViewState(
      text: message,
      placeholder: placeholder,
      minHeight: isMultiline ? 128 : MessageField.minimumHeight,
      cornerRadius: isMultiline ? nil : MessageField.minimumHeight / 2,
      textContainerInset: isMultiline ? nil : CGSize(width: 10, height: 8),
      showFocusRing: false,
      interceptEvents: isMultiline ? [] : [.newline]
    )
  }
}

// MARK: Actions

public enum MessageFieldAction: Equatable {
  case sendTapped, send(message: String)
  case textField(TCATextViewAction)
}
