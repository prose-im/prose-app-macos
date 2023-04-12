//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import ProseCoreFFI
import ProseCoreTCA
import SwiftUI
import Toolbox

struct MessageBar: View {
  static let verticalPadding: CGFloat = 12
  static let buttonsFont: Font = .system(size: 16)

  let store: StoreOf<MessageBarReducer>
  private var actions: ViewStore<Void, MessageBarReducer.Action>

  init(store: StoreOf<MessageBarReducer>) {
    self.store = store
    self.actions = ViewStore(self.store.stateless)
  }

  var body: some View {
    HStack(alignment: .messageBar, spacing: 16) {
      self.leadingButtons()
        .font(Self.buttonsFont)
        .alignmentGuide(.messageBar) {
          $0[VerticalAlignment.center] + MessageField.minimumHeight / 2
        }

      MessageField(
        store: self.store.scope(
          state: \.messageField,
          action: MessageBarReducer.Action.messageField
        )
      )
      .alignmentGuide(.top) {
        $0[VerticalAlignment.top] - Self.verticalPadding
      }
      .overlay(alignment: .typingIndicator) {
        WithViewStore(self.store.scope(state: \.typingUsers)) { typingUsers in
          TypingIndicator(typingUsers: typingUsers.state)
        }
      }

      self.trailingButtons()
        .font(Self.buttonsFont)
        .alignmentGuide(.messageBar) {
          $0[VerticalAlignment.center] + MessageField.minimumHeight / 2
        }
    }
    .padding(.vertical, Self.verticalPadding)
    .foregroundColor(.secondary)
    .padding(.horizontal, 20)
    .background {
      Rectangle()
        // TODO: [Rémi Bardon] Maybe add a material background here,
        //       to make it more beautiful with content going under
//        .fill(.ultraThinMaterial)
        .fill(.background)
        .overlay(alignment: .top, content: Divider.init)
    }
    .fixedSize(horizontal: false, vertical: true)
    .onAppear { self.actions.send(.onAppear) }
    .onDisappear { self.actions.send(.onDisappear) }
    // Make sure accessibility frame is correct
    .contentShape(Rectangle())
    .accessibilityElement(children: .contain)
  }

  private func leadingButtons() -> some View {
    HStack(spacing: 12) {
      Button { print("NOT IMPLEMENTED") } label: {
        Image(systemName: "textformat.alt")
      }
    }
    .buttonStyle(.plain)
  }

  private func trailingButtons() -> some View {
    HStack(spacing: 12) {
      Button { print("NOT IMPLEMENTED") } label: {
        Image(systemName: "paperclip")
      }

      Button { self.actions.send(.emojiButtonTapped) } label: {
        Image(systemName: "face.smiling")
      }
      .reactionPicker(
        store: self.store.scope(state: \.emojiPicker),
        action: MessageBarReducer.Action.emojiPicker,
        dismiss: .emojiPickerDismissed
      )
    }
    .buttonStyle(.plain)
  }
}

private struct MessageBarAlignment: AlignmentID {
  static func defaultValue(in context: ViewDimensions) -> CGFloat {
    context[VerticalAlignment.bottom]
  }
}

private extension VerticalAlignment {
  static let messageBar: Self = .init(MessageBarAlignment.self)
}

// extension Alignment {
//  static let messageBar: Self = .init(horizontal: .center, vertical: .messageBar)
// }
