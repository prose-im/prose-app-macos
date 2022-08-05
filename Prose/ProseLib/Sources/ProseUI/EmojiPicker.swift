//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import SwiftUI

public struct EmojiPickerState: Equatable {
  let emojis: [Character] = Array("👋👉👍😂😢😭😍😘😊🤯❤️🙏😛🚀⚠️😀😌😇🙃🙂🤩🥳🤨🙁😳🤔😐👀✅❌")

  let columnCount: Int = 5
  let fontSize: CGFloat = 24
  let spacing: CGFloat = 4

  var width: CGFloat { self.fontSize * 1.5 }
  var height: CGFloat { self.width }
}

public enum EmojiPickerAction: Equatable {
  case pick(Character)
}

struct EmojiPicker: View {
  let store: Store<EmojiPickerState, EmojiPickerAction>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      LazyVGrid(columns: Self.columns(state: viewStore.state), spacing: viewStore.spacing) {
        ForEach(viewStore.emojis, id: \.self) { emoji in
          Button { viewStore.send(.pick(emoji)) } label: {
            Text(String(emoji))
              .font(.system(size: viewStore.fontSize))
              .frame(width: viewStore.width, height: viewStore.height)
              .fixedSize()
          }
          .buttonStyle(.plain)
        }
      }
      .padding(viewStore.spacing * 2)
    }
  }

  static func gridItem(state: EmojiPickerState) -> GridItem {
    GridItem(.fixed(state.width), spacing: state.spacing)
  }
  static func columns(state: EmojiPickerState) -> [GridItem] {
    Array(repeating: Self.gridItem(state: state), count: state.columnCount)
  }
}

struct EmojiPicker_Previews: PreviewProvider {
  private struct Preview1: View {
    @State var text: String = ""
    var body: some View {
      VStack(alignment: .leading) {
        Text("Emoji: '\(text)'")
          .padding([.horizontal, .top])
        EmojiPicker(store: Store(
          initialState: .init(),
          reducer: Reducer { _, action, _ in
            switch action {
            case let .pick(emoji):
              text = String(emoji)
              return .none
            }
          },
          environment: ()
        ))
      }
      .fixedSize()
      .previewDisplayName("As a view")
    }
  }
  private struct Preview2: View {
    @State var text: String = ""
    @State private var isShowingPopover: Bool = false
    var body: some View {
      HStack {
        Text("Emoji: '\(text)'")
          .frame(width: 128, alignment: .leading)
        Toggle("Show?", isOn: $isShowingPopover)
          .popover(isPresented: $isShowingPopover) {
            EmojiPicker(store: Store(
              initialState: .init(),
              reducer: Reducer { _, action, _ in
                switch action {
                case let .pick(emoji):
                  text = String(emoji)
                  isShowingPopover = false
                  return .none
                }
              },
              environment: ()
            ))
          }
      }
      .padding()
      .fixedSize()
      .previewDisplayName("As a popover")
    }
  }

  static var previews: some View {
    Preview1()
    Preview2()
  }
}
