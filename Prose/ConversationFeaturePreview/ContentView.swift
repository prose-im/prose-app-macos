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
    let jid: JID = "preview@prose.org"
    let chatId: JID = "valerian@prose.org"
    var client = ProseClient.noop

    let chatSubject = CurrentValueSubject<[Message], Never>([
      Message(
        from: chatId,
        id: .init(rawValue: UUID().uuidString),
        kind: .normal,
        body: "Hello preview 👋",
        timestamp: .now - 200,
        isRead: true,
        isEdited: true,
        reactions: ["👋": [jid]]
      ),
      Message(
        from: jid,
        id: .init(rawValue: UUID().uuidString),
        kind: .normal,
        body: "Hi!",
        timestamp: .now - 12,
        isRead: true,
        isEdited: false,
        reactions: ["😃": [chatId]]
      ),
      Message(
        from: jid,
        id: .init(rawValue: UUID().uuidString),
        kind: .normal,
        body: "How are you?",
        timestamp: .now - 10,
        isRead: true,
        isEdited: false
      ),
    ])

    client.sendMessage = { _, body in
      .fireAndForget {
        chatSubject.value.append(
          .init(
            from: jid,
            id: .init(rawValue: UUID().uuidString),
            kind: .chat,
            body: body,
            timestamp: Date(),
            isRead: true,
            isEdited: false
          )
        )
      }
    }
    client.addReaction = { _, id, reaction in
      if let index: Int = chatSubject.value.firstIndex(where: { $0.id == id }) {
        chatSubject.value[index].reactions[reaction, default: Set<JID>()].insert(jid)
      }
      return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
    }
    client.toggleReaction = { _, id, reaction in
      if let index: Int = chatSubject.value.firstIndex(where: { $0.id == id }) {
        chatSubject.value[index].reactions.prose_toggle(jid, forKey: reaction)
      }
      return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
    }
    client.retractMessage = { id in
      // TODO: Send an error if message is not found?
      chatSubject.value.removeAll(where: { $0.id == id })
      return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
    }
    client.messagesInChat = { _ in
      chatSubject.setFailureType(to: EquatableError.self).eraseToEffect()
    }

    self.store = Store(
      initialState: ConversationState(chatId: chatId, loggedInUserJID: jid),
      reducer: conversationReducer,
      environment: ConversationEnvironment(
        proseClient: client,
        pasteboard: .live(),
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
