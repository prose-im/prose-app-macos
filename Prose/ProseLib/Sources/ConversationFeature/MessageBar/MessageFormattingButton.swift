//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import SwiftUI

struct MessageFormattingButton: View {
  let store: Store<MessageFormattingState, MessageFormattingAction>
  var body: some View {
    WithViewStore(self.store) { viewStore in
      Button { viewStore.send(.buttonTapped) } label: {
        Image(systemName: "textformat.alt")
      }
      .popover(isPresented: viewStore.binding(\.$isShowingPopover)) {
        Text("Not implemented yet.")
          .padding()
      }
    }
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
