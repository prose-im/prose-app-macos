//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Combine
import ComposableArchitecture
import ConversationFeature
import IdentifiedCollections
import ProseCoreTCA
import SwiftUI
import Toolbox

struct ContentView: View {
  let store: Store<ConversationState, ConversationAction>

  init() {
    let jid: JID = "preview@prose.org"
    let chatId: JID = "valerian@prose.org"
    var client = ProseClient.noop

    let messageSubject = CurrentValueSubject<IdentifiedArrayOf<Message>, Never>([
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

    let chats = CurrentValueSubject<[JID: ProseCoreTCA.Chat], Never>([
      chatId: Chat(
        jid: chatId,
        numberOfUnreadMessages: 0,
        participantStates: [chatId: .init(kind: .composing, timestamp: .now)]
      ),
    ])
    var participants: [JID: ProseCoreTCA.ChatState] {
      get { chats.value[chatId]!.participantStates }
      set { chats.value[chatId]!.participantStates = newValue }
    }

    client.sendMessage = { _, body in
      .fireAndForget {
        messageSubject.value.append(
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
    client.addReaction = { _, messageId, reaction in
      messageSubject.value[id: messageId]?.reactions.addReaction(reaction, for: jid)
      return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
    }
    client.toggleReaction = { _, messageId, reaction in
      messageSubject.value[id: messageId]?.reactions.toggleReaction(reaction, for: jid)
      return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
    }
    client.retractMessage = { _, messageId in
      // TODO: Send an error if message is not found?
      messageSubject.value.remove(id: messageId)
      return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
    }
    client.messagesInChat = { _ in
      messageSubject.setFailureType(to: EquatableError.self).eraseToEffect()
    }
    client.sendChatState = { (_, kind: ChatState.Kind) in
      participants[jid] = .init(kind: kind, timestamp: .now)
      return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
    }
    client.activeChats = {
      chats.setFailureType(to: EquatableError.self).eraseToEffect()
    }
    client.updateMessage = { _, messageId, body in
      messageSubject.value[id: messageId]?.body = body
      return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
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
