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

struct MessageBarTextField: View {
  typealias State = MessageBarTextFieldState
  typealias Action = MessageBarTextFieldAction

  @Environment(\.redactionReasons) private var redactionReasons

  @FocusState private var isFocused: Bool

  let store: Store<State, Action>
  private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

  let cornerRadius: CGFloat

  var body: some View {
    WithViewStore(self.store) { viewStore in
      let message = viewStore.binding(\.$message)
      HStack(alignment: .bottom, spacing: 0) {
        TextEditor(text: message)
          .focused(self.$isFocused)
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
          .onSubmit(of: .text) { actions.send(.sendTapped) }
          .accessibility(hint: Text(viewStore.placeholder))

        if !viewStore.hideSendButton {
          Button { actions.send(.sendTapped) } label: {
            Image(systemName: "paperplane.circle.fill")
              .font(.system(size: 24, weight: .regular))
              .foregroundColor(.accentColor)
              .padding(3)
          }
          .buttonStyle(.plain)
          .unredacted()
          .disabled(redactionReasons.contains(.placeholder))
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
      .onDisappear { self.actions.send(.onDisappear) }
    }
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

enum MessageBarTextFieldEffectToken: Hashable, CaseIterable {
  case pauseTyping
}

public extension DispatchQueue.SchedulerTimeType.Stride {
  static let pauseTypingDebounceDuration: Self = .seconds(30)
}

public let messageBarTextFieldReducer: Reducer<
  MessageBarTextFieldState,
  MessageBarTextFieldAction,
  ConversationEnvironment
> = Reducer { state, action, environment in
  switch action {
  case .sendTapped where !state.message.isEmpty:
    let content = state.message
    state.message = ""
    return Effect(value: .send(message: content))

  case let .setChatState(chatState):
    return environment.proseClient
      .sendChatState(state.chatId, chatState)
      .fireAndForget()

  case .onDisappear:
    return .cancel(token: MessageBarTextFieldEffectToken.self)

  case .sendTapped, .send, .binding:
    return .none
  }
}
.binding()
.onChange(of: TextFieldState.init) { current, state, _, environment in
  if current.isEditingAMessage {
    // Don't send XMPP chat states when editing a message
    return .none
  }
  if !current.isFocused || current.message.isEmpty {
    // If the textfield is not focused or empty we don't consider the user typing.
    return .merge([
      environment.proseClient
        .sendChatState(state.chatId, .active)
        .fireAndForget(),
      .cancel(id: MessageBarTextFieldEffectToken.pauseTyping),
    ])
  } else {
    return .merge([
      environment.proseClient
        .sendChatState(state.chatId, .composing)
        .fireAndForget(),
      Effect(value: .setChatState(.paused))
        .delay(for: .pauseTypingDebounceDuration, scheduler: environment.mainQueue)
        .eraseToEffect()
        .cancellable(id: MessageBarTextFieldEffectToken.pauseTyping, cancelInFlight: true),
    ])
  }
}

private struct TextFieldState: Equatable {
  var isEditingAMessage: Bool
  var message: String
  var isFocused: Bool

  init(_ state: MessageBarTextFieldState) {
    self.message = state.message
    self.isFocused = state.isFocused
    self.isEditingAMessage = state.isEditingAMessage
  }
}

// MARK: State

public struct MessageBarTextFieldState: Equatable {
  let chatId: JID
  let placeholder: String
  let isEditingAMessage: Bool
  @BindableState var isFocused: Bool = false
  @BindableState var message: String

  var hideSendButton: Bool { self.isEditingAMessage }

  init(chatId: JID, placeholder: String, isEditingAMessage: Bool = false, message: String = "") {
    self.chatId = chatId
    self.placeholder = placeholder
    self.isEditingAMessage = isEditingAMessage
    self.message = message
  }
}

// MARK: Actions

public enum MessageBarTextFieldAction: Equatable, BindableAction {
  case sendTapped
  case send(message: String)
  case setChatState(ProseCoreTCA.ChatState.Kind)
  case onDisappear
  case binding(BindingAction<MessageBarTextFieldState>)
}

// MARK: - Previews

#if DEBUG
  struct MessageBarTextField_Previews: PreviewProvider {
    private struct Preview: View {
      let state: MessageBarTextFieldState
      let height: CGFloat

      init(state: MessageBarTextFieldState, height: CGFloat = 32) {
        self.state = state
        self.height = height
      }

      var body: some View {
        MessageBarTextField(store: Store(
          initialState: state,
          reducer: messageBarTextFieldReducer,
          environment: .init(proseClient: .noop, pasteboard: .live(), mainQueue: .main)
        ), cornerRadius: MessageBar.textFieldCornerRadius)
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
