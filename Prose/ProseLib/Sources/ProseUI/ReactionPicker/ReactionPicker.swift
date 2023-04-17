//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import SwiftUI
import SwiftUINavigation

public struct ReactionPicker: View {
  let store: StoreOf<ReactionPickerReducer>

  public init(store: StoreOf<ReactionPickerReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(self.store) { viewStore in
      LazyVGrid(columns: Self.columns(state: viewStore.state), spacing: viewStore.spacing) {
        ForEach(viewStore.reactions, id: \.self) { emoji in
          let isSelected: Bool = viewStore.selected.contains(emoji)
          Button {
            viewStore.send(isSelected ? .deselect(emoji) : .select(emoji))
          } label: {
            Text(emoji)
              .font(.system(size: viewStore.fontSize))
              .frame(width: viewStore.width, height: viewStore.height)
              .modifier(Selected(viewStore.selected.contains(emoji)))
              .fixedSize()
          }
          .buttonStyle(.plain)
          .contentShape(Rectangle())
        }
      }
      .padding(viewStore.spacing * 2)
    }
  }

  static func gridItem(state: ReactionPickerReducer.State) -> GridItem {
    GridItem(.fixed(state.width), spacing: state.spacing)
  }

  static func columns(state: ReactionPickerReducer.State) -> [GridItem] {
    Array(repeating: Self.gridItem(state: state), count: state.columnCount)
  }
}

private struct Selected: ViewModifier {
  let isSelected: Bool

  init(_ isSelected: Bool) {
    self.isSelected = isSelected
  }

  func body(content: Content) -> some View {
    content
      .compositingGroup()
      .background {
        if self.isSelected {
          RoundedRectangle(cornerRadius: 8)
            .strokeBorder(.selection, lineWidth: 2)
            // Make sure the border looks good on material backgrounds
            // (otherwise not enough contrast)
            .blendMode(.plusDarker)
        }
      }
      .accessibilityAddTraits(self.isSelected ? .isSelected : [])
  }
}

public extension View {
  func reactionPicker<Action>(
    store: Store<ReactionPickerReducer.State?, Action>,
    action: @escaping (ReactionPickerReducer.Action) -> Action,
    dismiss: Action
  ) -> some View {
    WithViewStore(store) { viewStore in
      self.popover(unwrapping: viewStore.binding(send: dismiss)) { $state in
        ReactionPicker(store: store.scope(
          state: { _ in $state.wrappedValue },
          action: action
        ))
      }
    }
  }
}
