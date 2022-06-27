//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Combine
import ComposableArchitecture
import ConversationFeature
import ProseCoreTCA
import SwiftUI
import Toolbox

struct ContentView: View {
  let store: Store<ConversationState, ConversationAction>

  init() {
    var client = ProseClient.noop

    let chatSubject = CurrentValueSubject<[Message], Never>([])

    client.sendMessage = { jid, body in
      .fireAndForget {
        chatSubject.value.append(
          .init(
            from: jid,
            id: .init(rawValue: UUID().uuidString),
            kind: nil,
            body: body,
            timestamp: Date(),
            isRead: true,
            isEdited: false
          )
        )
      }
    }
    client.messagesInChat = { _ in
      chatSubject.setFailureType(to: EquatableError.self).eraseToEffect()
    }

    self.store = Store(
      initialState: ConversationState(
        chatId: "valerian@prose.org"
      ),
      reducer: conversationReducer,
      environment: ConversationEnvironment(
        proseClient: client,
        mainQueue: .main
      )
    )
  }

  var body: some View {
    ConversationScreen(store: self.store)
      .frame(minWidth: 960, minHeight: 320)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
