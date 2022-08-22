//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import SwiftUI

struct MessageAttachmentsButton: View {
  @Environment(\.redactionReasons) private var redactionReasons

  let store: Store<MessageAttachmentsState, MessageAttachmentsAction>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      Button { viewStore.send(.buttonTapped) } label: {
        Image(systemName: "paperclip")
      }
    }
    .unredacted()
    .disabled(self.redactionReasons.contains(.placeholder))
    // https://github.com/prose-im/prose-app-macos/issues/48
    .disabled(true)
  }
}

let messageAttachmentsReducer = Reducer<
  MessageAttachmentsState,
  MessageAttachmentsAction,
  Void
> { _, action, _ in
  switch action {
  case .buttonTapped:
    logger.warning("Message attachments not supported yet.")
    return .none
  }
}

public struct MessageAttachmentsState: Equatable {}

public enum MessageAttachmentsAction: Equatable {
  case buttonTapped
}
