//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Assets
import ComposableArchitecture
import SwiftUI

struct MessageField: View {
  static let verticalSpacing: CGFloat = 8
  static let horizontalSpacing: CGFloat = 10
  static let minimumHeight: CGFloat = 32

  @FocusState private var isFocused: Bool

  let store: StoreOf<MessageFieldReducer>
  @ObservedObject var viewStore: ViewStoreOf<MessageFieldReducer>

  let cornerRadius: CGFloat

  init(store: StoreOf<MessageFieldReducer>) {
    self.store = store
    self.viewStore = ViewStore(self.store)
    self.cornerRadius = Self.minimumHeight / 2
  }

  var body: some View {
    HStack(alignment: .bottom, spacing: 0) {
      TextEditor(text: self.viewStore.binding(\.$message))
        // TextEditor has some insets we need to counter
        .padding(.leading, -5)
        // TextEditor has no placeholder, we need to add it ourselves
        .overlay(alignment: .topLeading) {
          if self.viewStore.message.isEmpty {
            Text("Placeholder - FIXME")
              .foregroundColor(Color(nsColor: NSColor.placeholderTextColor))
              .allowsHitTesting(false)
              .accessibility(hidden: true)
          }
        }
        .focused(self.$isFocused)
        .padding(.vertical, Self.verticalSpacing)
        .padding(.leading, Self.horizontalSpacing)
        .font(.body)
        .foregroundColor(.primary)
        .textFieldStyle(.plain)
        .onSubmit(of: .text) { self.viewStore.send(.sendTapped) }
      // .accessibility(hint: Text(viewStore.placeholder))

      Button { self.viewStore.send(.sendTapped) } label: {
        Image(systemName: "paperplane.circle.fill")
          .font(.system(size: 24))
          .foregroundColor(.accentColor)
          .frame(width: 32, height: 32)
      }
      .buttonStyle(.plain)
    }
    .background(
      ZStack {
        RoundedRectangle(cornerRadius: self.cornerRadius)
          .fill(Color(nsColor: .textBackgroundColor))
        RoundedRectangle(cornerRadius: self.cornerRadius)
          .strokeBorder(Colors.Border.secondary.color)
      }
    )
    .synchronize(self.viewStore.binding(\.$isFocused), self.$isFocused)
  }
}
