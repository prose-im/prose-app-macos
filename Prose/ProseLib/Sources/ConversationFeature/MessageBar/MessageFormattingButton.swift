//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import ProseUI
import SwiftUI

private let l10n = L10n.Content.MessageBar.Formatting.self

struct MessageFormattingButton: View {
  @Environment(\.redactionReasons) private var redactionReasons

  let store: Store<MessageFormattingState, MessageFormattingAction>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      Button { viewStore.send(.buttonTapped) } label: {
        Label(l10n.Button.axLabel, systemImage: "textformat.alt")
      }
      .labelStyle(.iconOnly)
      .popover(isPresented: viewStore.binding(\.$isShowingPopover), content: self.popover)
      .accessibility(hint: Text(verbatim: l10n.Button.axHint))
    }
    .unredacted()
    .disabled(self.redactionReasons.contains(.placeholder))
  }

  @ViewBuilder
  func popover() -> some View {
    let buttonWidth: CGFloat = 36
    VStack {
      GroupBox {
        ControlGroup {
          Button {} label: {
            Label(l10n.FontSection.bold, systemImage: "bold")
          }
          Button {} label: {
            Label(l10n.FontSection.italic, systemImage: "italic")
          }
          Button {} label: {
            Label(l10n.FontSection.underline, systemImage: "underline")
          }
          Button {} label: {
            Label(l10n.FontSection.strikethrough, systemImage: "strikethrough")
          }
        }
        .frame(width: 4 * buttonWidth)
      } label: {
        Text(verbatim: l10n.FontSection.title)
          .fontWeight(.medium)
          .frame(maxHeight: .infinity)
      }
      Divider()
        .opacity(0.5)
      GroupBox {
        ControlGroup {
          Button {} label: {
            Label(l10n.ListsSection.bulletedList, systemImage: "list.bullet")
          }
          Button {} label: {
            Label(l10n.ListsSection.numberedList, systemImage: "list.number")
          }
          Button {} label: {
            Label(l10n.ListsSection.quoteBlock, systemImage: "text.quote")
          }
          // https://github.com/prose-im/prose-app-macos/issues/48
          .disabled(true)
        }
        .frame(width: 3 * buttonWidth)
      } label: {
        Text(verbatim: l10n.ListsSection.title)
          .fontWeight(.medium)
          .frame(maxHeight: .infinity)
      }
      Divider()
        .opacity(0.5)
      GroupBox {
        ControlGroup {
          Button {} label: {
            Label(l10n.InsertsSection.link, systemImage: "link")
          }
          Button {} label: {
            Label(l10n.InsertsSection.code, systemImage: "chevron.left.forwardslash.chevron.right")
          }
        }
        .frame(width: 2 * buttonWidth)
      } label: {
        Text(verbatim: l10n.InsertsSection.title)
          .fontWeight(.medium)
          .frame(maxHeight: .infinity)
      }
    }
    .groupBoxStyle(FormGroupBoxStyle(
      firstColumnWidth: 64,
      titleAlignment: .leading
    ))
    .labelStyle(.iconOnly)
    .fixedSize()
    .padding(12)
    .font(.body)
  }
}

let messageFormattingReducer = Reducer<
  MessageFormattingState,
  MessageFormattingAction,
  Void
> { state, action, _ in
  switch action {
  case .buttonTapped:
    state.isShowingPopover = true
    return .none

  case .binding:
    return .none
  }
}.binding()

public struct MessageFormattingState: Equatable {
  @BindableState var isShowingPopover: Bool = false
}

public enum MessageFormattingAction: Equatable, BindableAction {
  case buttonTapped
  case binding(BindingAction<MessageFormattingState>)
}

#if DEBUG
  struct MessageFormattingButton_Previews: PreviewProvider {
    static var previews: some View {
      let preview = MessageFormattingButton(store: Store(
        initialState: MessageFormattingState(
          isShowingPopover: false
        ),
        reducer: messageFormattingReducer,
        environment: ()
      ))
      VStack(alignment: .leading) {
        GroupBox("Button") {
          preview
        }
        GroupBox("Popover") {
          preview.popover()
            .border(Color.red)
        }
      }
      .padding()
    }
  }
#endif
