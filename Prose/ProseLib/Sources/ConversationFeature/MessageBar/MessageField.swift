//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import enum Assets.Colors
import ComposableArchitecture
import ProseCoreTCA
import ProseUI
import SwiftUI
import TcaHelpers

// MARK: - View

struct MessageField: View {
  typealias State = MessageFieldState
  typealias Action = MessageFieldAction

  static let verticalSpacing: CGFloat = 8
  static let horizontalSpacing: CGFloat = 10
  static let minimumHeight: CGFloat = 32

  @Environment(\.redactionReasons) private var redactionReasons

  @FocusState private var isFocused: Bool

  let store: Store<State, Action>

  let cornerRadius: CGFloat

  init(store: Store<State, Action>, cornerRadius: CGFloat? = nil) {
    self.store = store
    self.cornerRadius = cornerRadius ?? Self.minimumHeight / 2
  }

  var body: some View {
    WithViewStore(self.store) { viewStore in
      HStack(alignment: .bottom, spacing: 0) {
        Self.textField(
          text: viewStore.binding(\.$message),
          placeholder: viewStore.placeholder,
          isMultiline: viewStore.isMultiline
        )
        .focused(self.$isFocused)
        .padding(.vertical, Self.verticalSpacing)
        .padding(.leading, Self.horizontalSpacing)
        .padding(.trailing, viewStore.hideSendButton ? Self.horizontalSpacing : 0)
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
              .frame(width: 32, height: 32)
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

  @ViewBuilder
  static func textField(
    text: Binding<String>,
    placeholder: String,
    isMultiline: Bool
  ) -> some View {
    if isMultiline {
      TextEditor(text: text)
        // TextEditor has some insets we need to counter
        .padding(.leading, -5)
        // TextEditor has no placeholder, we need to add it ourselves
        .overlay(alignment: .topLeading) {
          if text.wrappedValue.isEmpty {
            Text(placeholder)
              .foregroundColor(Color(nsColor: NSColor.placeholderTextColor))
              .allowsHitTesting(false)
              .accessibility(hidden: true)
          }
        }
    } else {
      TextField(placeholder, text: text)
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
  let isMultiline: Bool
  let hideSendButton: Bool
  @BindableState var isFocused: Bool = false
  @BindableState var message: String

  init(
    chatId: JID,
    placeholder: String,
    isMultiline: Bool = false,
    hideSendButton: Bool = false,
    message: String = ""
  ) {
    self.chatId = chatId
    self.placeholder = placeholder
    self.isMultiline = isMultiline
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
      let cornerRadius: CGFloat?

      init(
        state: MessageFieldState,
        height: CGFloat = 32,
        cornerRadius: CGFloat? = nil
      ) {
        self.state = state
        self.height = height
        self.cornerRadius = cornerRadius
      }

      var body: some View {
        MessageField(store: Store(
          initialState: state,
          reducer: messageFieldReducer,
          environment: .init(proseClient: .noop, pasteboard: .noop, mainQueue: .main)
        ), cornerRadius: self.cornerRadius)
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
        GroupBox("High, single line") {
          Preview(
            state: .init(chatId: "preview@prose.org", placeholder: "Message Valerian"),
            height: 128
          )
        }
        GroupBox("High, multi line") {
          Preview(
            state: .init(
              chatId: "preview@prose.org",
              placeholder: "Message Valerian",
              isMultiline: true
            ),
            height: 128
          )
        }
        GroupBox("Multi line, small corners") {
          Preview(
            state: .init(
              chatId: "preview@prose.org",
              placeholder: "Message Valerian",
              isMultiline: true
            ),
            cornerRadius: 8
          )
        }
        GroupBox("Single line vs multi line") {
          VStack(spacing: 0) {
            Preview(state: .init(
              chatId: "preview@prose.org",
              placeholder: "Message Valerian",
              message: "This is a message that was written."
            ))
            .overlay {
              Preview(state: .init(
                chatId: "preview@prose.org",
                placeholder: "Message Valerian",
                isMultiline: true,
                message: "This is a message that was written."
              ))
              .blendMode(.difference)
//              .blendMode(.multiply)
//              .opacity(0.5)
            }
            Preview(state: .init(
              chatId: "preview@prose.org",
              placeholder: "Message Valerian",
              message: ""
            ))
            .overlay {
              Preview(state: .init(
                chatId: "preview@prose.org",
                placeholder: "Message Valerian",
                isMultiline: true,
                message: ""
              ))
//              .blendMode(.difference)
              .blendMode(.multiply)
//              .opacity(0.5)
            }
          }
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
