//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import ProseBackend
import ProseCoreTCA
import SwiftUI

// MARK: - View

struct EditMessageView: View {
  let store: StoreOf<EditMessageReducer>

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
          #warning("FIXME")
//          MessageFormattingButton(store: self.store.scope(
//            state: \.formatting,
//            action: EditMessageAction.formatting
//          ))
//          MessageEmojisButton(store: self.store.scope(
//            state: \.emojis,
//            action: EditMessageAction.emojis
//          ))
        }
        .buttonStyle(.plain)
        .font(MessageBar.buttonsFont)
        Spacer()
        WithViewStore(self.store.scope(state: \.childState.isConfirmButtonDisabled)) { viewStore in
          Button(L10n.Content.EditMessage.CancelAction.title, role: .cancel) {
            viewStore.send(.cancelTapped)
          }
          .buttonStyle(.bordered)
          Button(L10n.Content.EditMessage.ConfirmAction.title) { viewStore.send(.confirmTapped) }
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
