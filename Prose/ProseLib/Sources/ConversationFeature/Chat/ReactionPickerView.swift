//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import ProseUI
import SwiftUI

final class ReactionPickerView<Action>: NSHostingView<
  ModifiedContent<AnyView, ReactionPickerPopup<Action>>
> {
  typealias Content = ModifiedContent<AnyView, ReactionPickerPopup<Action>>

  var store: Store<MessageReactionPickerState, Action> {
    didSet {
      self.rootView = Self.body(store: self.store, action: self.action, dismiss: self.dismiss)
    }
  }

  let action: CasePath<Action, ReactionPickerReducer.Action>
  let dismiss: Action

  init(
    store: Store<MessageReactionPickerState, Action>,
    action: CasePath<Action, ReactionPickerReducer.Action>,
    dismiss: Action
  ) {
    self.store = store
    self.action = action
    self.dismiss = dismiss

    super.init(rootView: Self.body(store: store, action: action, dismiss: dismiss))
  }

  @MainActor required init(rootView _: Content) {
    fatalError("init(rootView:) has not been implemented")
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  static func body(
    store: Store<MessageReactionPickerState, Action>,
    action: CasePath<Action, ReactionPickerReducer.Action>,
    dismiss: Action
  ) -> Content {
    AnyView(Color.clear)
      .modifier(ReactionPickerPopup(store: store, action: action, dismiss: dismiss))
  }
}

struct ReactionPickerPopup<Action>: ViewModifier {
  let store: Store<MessageReactionPickerState, Action>
  let action: CasePath<Action, ReactionPickerReducer.Action>
  let dismiss: Action

  func body(content: Content) -> some View {
    content
      .reactionPicker(
        store: self.store.scope(state: { $0.pickerState }),
        action: self.action.embed(_:),
        dismiss: self.dismiss
      )
  }
}
