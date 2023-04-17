//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import ProseBackend
import ProseUI
import SwiftUI

struct EditMessageView: View {
  let store: StoreOf<EditMessageReducer>
  let viewStore: ViewStoreOf<EditMessageReducer>

  init(store: StoreOf<EditMessageReducer>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }

  var body: some View {
    VStack(alignment: .leading) {
      Text(L10n.Content.EditMessage.title)
        .font(.title2.bold())
      MessageField(store: self.store.scope(
        state: \.messageField,
        action: EditMessageReducer.Action.messageField
      ))
    }
    .safeAreaInset(edge: .bottom, spacing: 12) {
      HStack {
        Group {
          Button { print("NOT IMPLEMENTED") } label: {
            Image(systemName: "paperclip")
          }

          Button { self.viewStore.send(.emojiButtonTapped) } label: {
            Image(systemName: "face.smiling")
          }
          .reactionPicker(
            store: self.store.scope(state: \.emojiPicker),
            action: EditMessageReducer.Action.emojiPicker,
            dismiss: .emojiPickerDismissed
          )
        }
        .buttonStyle(.plain)
        .font(MessageBar.buttonsFont)
        Spacer()
        WithViewStore(self.store.scope(state: \.childState.isConfirmButtonEnabled)) { viewStore in
          Button(L10n.Content.EditMessage.CancelAction.title, role: .cancel) {
            viewStore.send(.cancelTapped)
          }
          .buttonStyle(.bordered)
          Button(L10n.Content.EditMessage.ConfirmAction.title) { viewStore.send(.confirmTapped) }
            .buttonStyle(.borderedProminent)
            .disabled(!viewStore.state)
        }
      }
      .controlSize(.large)
    }
    .padding()
    .frame(width: 500)
    .frame(minHeight: 200)
  }
}
