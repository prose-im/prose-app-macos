//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppLocalization
import Assets
import ComposableArchitecture
import SwiftUI
import Toolbox

struct MessageField: View {
  struct ViewState: Equatable {
    var message: String
    var placeholder: String
    var isFocused: Bool
    var isSendButtonEnabled: Bool
  }

  static let verticalSpacing: CGFloat = 8
  static let horizontalSpacing: CGFloat = 10
  static let minimumHeight: CGFloat = 32

  @FocusState private var isFocused: Bool

  let store: StoreOf<MessageFieldReducer>
  @ObservedObject var viewStore: ViewStore<ViewState, MessageFieldReducer.Action>

  let cornerRadius: CGFloat

  init(store: StoreOf<MessageFieldReducer>) {
    self.store = store
    self.viewStore = ViewStore(self.store.scope(state: ViewState.init))
    self.cornerRadius = Self.minimumHeight / 2
  }

  var body: some View {
    HStack(alignment: .bottom, spacing: 0) {
      TextEditor(
        text: self.viewStore
          .binding(get: \.message, send: MessageFieldReducer.Action.messageChanged)
      )
      // TextEditor has some insets we need to counter
      .padding(.leading, -5)
      // TextEditor has no placeholder, we need to add it ourselves
      .overlay(alignment: .topLeading) {
        if self.viewStore.message.isEmpty {
          Text(verbatim: self.viewStore.placeholder)
            .foregroundColor(Color(nsColor: NSColor.placeholderTextColor))
            .allowsHitTesting(false)
        }
      }
      .focused(self.$isFocused)
      .padding(.vertical, Self.verticalSpacing)
      .padding(.leading, Self.horizontalSpacing)
      .font(.body)
      .foregroundColor(.primary)
      .textFieldStyle(.plain)
      .onSubmit(of: .text) { self.viewStore.send(.sendButtonTapped) }

      Button { self.viewStore.send(.sendButtonTapped) } label: {
        Image(systemName: "paperplane.circle.fill")
          .font(.system(size: 24))
          .foregroundColor(.accentColor)
          .frame(width: 32, height: 32)
      }
      .buttonStyle(.plain)
      .disabled(!self.viewStore.isSendButtonEnabled)
    }
    .background(
      ZStack {
        RoundedRectangle(cornerRadius: self.cornerRadius)
          .fill(Color(nsColor: .textBackgroundColor))
        RoundedRectangle(cornerRadius: self.cornerRadius)
          .strokeBorder(Colors.Border.secondary.color)
      }
    )
    .synchronize(
      self.viewStore.binding(get: \.isFocused, send: MessageFieldReducer.Action.focusChanged),
      self.$isFocused
    )
  }
}

extension MessageField.ViewState {
  init(_ state: MessageFieldReducer.State) {
    self.message = state.message
    self.placeholder = L10n.Content.MessageBar.fieldPlaceholder(
      state.userInfos[state.chatId]?.name ?? state.chatId.rawValue
    )
    self.isFocused = state.isFocused
    self.isSendButtonEnabled = state.childState.isSendButtonEnabled
  }
}
