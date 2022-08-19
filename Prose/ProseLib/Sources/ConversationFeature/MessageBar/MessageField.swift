//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import Assets
import ComposableArchitecture
import ProseCoreTCA
import ProseUI
import SwiftUI
import TcaHelpers

private let l10n = L10n.Content.MessageBar.self

// MARK: - View

/// A ``MessageField`` with "composing…" logic.
struct MessageField: View {
  typealias State = MessageFieldState
  typealias Action = MessageFieldAction

  @Environment(\.redactionReasons) private var redactionReasons

  @FocusState private var isFocused: Bool

  let store: Store<State, Action>

  let cornerRadius: CGFloat

  var body: some View {
    WithViewStore(self.store) { viewStore in
      let message = viewStore.binding(\.$message)
      HStack(alignment: .bottom, spacing: 0) {
        TextEditor(text: message)
          .focused(self.$isFocused)
          // TextEditor has no placeholder, we need to add it ourselves
          .overlay(alignment: .topLeading) {
            if viewStore.message.isEmpty {
              Text(viewStore.placeholder)
                .foregroundColor(.secondary)
                // TextEditor has some insets we need to manually set here
                .padding(.leading, 5)
                .allowsHitTesting(false)
                .accessibility(hidden: true)
            }
          }
          .padding(.vertical, 8)
          .padding(.leading, self.cornerRadius / 2)
          .padding(.trailing, viewStore.hideSendButton ? self.cornerRadius / 2 : 0)
          .font(.body)
          .foregroundColor(.primary)
          .textFieldStyle(.plain)
          .onSubmit(of: .text) { viewStore.send(.sendTapped) }
          .accessibility(hint: Text(viewStore.placeholder))

        if !viewStore.hideSendButton {
          Button { viewStore.send(.sendTapped) } label: {
            Image(systemName: "paperplane.circle.fill")
              .font(.system(size: 24))
              .foregroundColor(.accentColor)
              .padding(3)
          }
          .buttonStyle(.plain)
          .unredacted()
          .disabled(self.redactionReasons.contains(.placeholder))
        }
      }
      .background(
        ZStack {
          RoundedRectangle(cornerRadius: self.cornerRadius)
            .fill(Color(nsColor: .textBackgroundColor))
          RoundedRectangle(cornerRadius: self.cornerRadius)
            .strokeBorder(Colors.Border.secondary.color)
        }
      )
      .synchronize(viewStore.binding(\.$isFocused), self.$isFocused)
    }
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let messageFieldReducer = Reducer<
  MessageFieldState,
  MessageFieldAction,
  ConversationEnvironment
> { state, action, _ in
  switch action {
  case .sendTapped where !state.message.isEmpty:
    let content = state.message
    return Effect(value: .send(message: state.message))

  case .sendTapped, .send, .binding:
    return .none
  }
}
.binding()

// MARK: State

public struct MessageFieldState: Equatable {
  let chatId: JID
  let placeholder: String
  let hideSendButton: Bool
  @BindableState var isFocused: Bool = false
  @BindableState var message: String

  init(chatId: JID, placeholder: String, hideSendButton: Bool = false, message: String = "") {
    self.chatId = chatId
    self.placeholder = placeholder
    self.hideSendButton = hideSendButton
    self.message = message
  }
}

// MARK: Actions

public enum MessageFieldAction: Equatable, BindableAction {
  case sendTapped, send(message: String)
  case binding(BindingAction<MessageFieldState>)
}

// MARK: - Previews

#if DEBUG
  struct MessageField_Previews: PreviewProvider {
    private struct Preview: View {
      let state: MessageFieldState
      let height: CGFloat

      init(state: MessageFieldState, height: CGFloat = 32) {
        self.state = state
        self.height = height
      }

      var body: some View {
        MessageField(store: Store(
          initialState: state,
          reducer: messageFieldReducer,
          environment: .init(proseClient: .noop, pasteboard: .noop, mainQueue: .main)
        ), cornerRadius: MessageBar.messageFieldCornerRadius)
          .frame(width: 500)
          .frame(minHeight: self.height)
          .padding(8)
      }
    }

    static var previews: some View {
      let previews = VStack(spacing: 16) {
        GroupBox("Simple message") {
          Preview(state: .init(
            chatId: "preview@prose.org",
            placeholder: "Message Valerian",
            message: "This is a message that was written."
          ))
        }
        GroupBox("Long message") {
          Preview(state: .init(
            chatId: "preview@prose.org",
            placeholder: "Message Valerian",
            message: "This is a \(Array(repeating: "very", count: 20).joined(separator: " ")) long message that was written."
          ))
        }
        GroupBox("Long username") {
          Preview(state: .init(
            chatId: "preview@prose.org",
            placeholder: "Very \(Array(repeating: "very", count: 20).joined(separator: " ")) long placeholder"
          ))
        }
        GroupBox("Empty") {
          Preview(state: .init(chatId: "preview@prose.org", placeholder: "Message Valerian"))
        }
        GroupBox("High") {
          Preview(
            state: .init(chatId: "preview@prose.org", placeholder: "Message Valerian"),
            height: 128
          )
        }
        GroupBox("Colorful background") {
          Preview(state: .init(chatId: "preview@prose.org", placeholder: "Message Valerian"))
            .background(Color.pink)
        }
      }
      .padding(8)
      .fixedSize(horizontal: false, vertical: true)
      previews
        .preferredColorScheme(.light)
        .previewDisplayName("Light")
      previews
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark")
    }
  }
#endif
