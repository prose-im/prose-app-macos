//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import ProseCoreTCA
import ProseUI
import SwiftUI

struct MessageEmojisButton: View {
  @Environment(\.redactionReasons) private var redactionReasons

  let store: Store<MessageEmojisState, MessageEmojisAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      Button { viewStore.send(.buttonTapped) } label: {
        Image(systemName: "face.smiling")
      }
      .reactionPicker(
        store: self.store.scope(state: \.reactionPicker),
        action: MessageEmojisAction.reactionPicker,
        dismiss: .reactionPickerDismissed
      )
    }
    .unredacted()
    .disabled(self.redactionReasons.contains(.placeholder))
  }
}

let messageEmojisReducer = Reducer<
  MessageEmojisState,
  MessageEmojisAction,
  Void
> { state, action, _ in
  switch action {
  case .buttonTapped:
    state.reactionPicker = .init()
    return .none

  case let .reactionPicker(.select(reaction)):
    state.reactionPicker = nil
    return Effect(value: .insert(reaction))

  case .reactionPickerDismissed:
    state.reactionPicker = nil
    return .none

  case .reactionPicker, .insert:
    return .none
  }
}

public struct MessageEmojisState: Equatable {
  var reactionPicker: ReactionPickerState?
}

public enum MessageEmojisAction: Equatable {
  case buttonTapped
  case reactionPicker(ReactionPickerAction), reactionPickerDismissed
  case insert(Reaction)
}
