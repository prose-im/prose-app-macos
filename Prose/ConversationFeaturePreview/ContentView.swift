//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import Combine
import ComposableArchitecture
import ConversationFeature
import IdentifiedCollections
import Mocks
import ProseCore
import SwiftUI
import Toolbox

struct ContentView: View {
  let store: StoreOf<ConversationScreenReducer>

  init() {
    let eventsSubject = PassthroughSubject<ClientEvent, Never>()

    var messages: [Message] = [
      .mock(
        id: .init(UUID().uuidString),
        from: .johnDoe,
        body: "Hello preview 👋",
        timestamp: .now - 200,
        isRead: true,
        isEdited: true,
        reactions: [.init(emoji: "👋", from: [.janeDoe])]
      ),
      .mock(
        id: .init(UUID().uuidString),
        from: .janeDoe,
        body: "Hi!",
        timestamp: .now - 12,
        isRead: true,
        isEdited: false,
        reactions: [.init(emoji: "😃", from: [.johnDoe])]
      ),
      .mock(
        id: .init(UUID().uuidString),
        from: .johnDoe,
        body: "How are you?",
        timestamp: .now - 10,
        isRead: true,
        isEdited: false
      ),
    ]

    var coreClient = ProseCoreClient.noop
    coreClient.events = {
      AsyncStream(eventsSubject.values)
    }
    coreClient.sendMessage = { conversation, text in
      let id = MessageId(UUID().uuidString)
      messages.append(
        .mock(
          id: id,
          from: .janeDoe,
          body: text,
          timestamp: Date(),
          isRead: true
        )
      )
      eventsSubject.send(.messagesAppended(conversation: conversation, messageIds: [id]))
    }
    coreClient.toggleReactionToMessage = { conversation, messageId, emoji in
      guard let messageIdx = messages.firstIndex(where: { $0.id == messageId }) else {
        return
      }

      defer {
        eventsSubject.send(.messagesUpdated(conversation: conversation, messageIds: [messageId]))
      }

      guard let reactionIdx = messages[messageIdx].reactions
        .firstIndex(where: { $0.emoji == emoji })
      else {
        messages[messageIdx].reactions.append(.init(emoji: emoji, from: [.janeDoe]))
        return
      }

      guard let userIdx = messages[messageIdx].reactions[reactionIdx].from
        .firstIndex(where: { $0 == .janeDoe })
      else {
        messages[messageIdx].reactions[reactionIdx].from.append(.janeDoe)
        return
      }

      messages[messageIdx].reactions[reactionIdx].from.remove(at: userIdx)
      messages[messageIdx].reactions.removeAll(where: { $0.from.isEmpty })
    }
    coreClient.retractMessage = { conversation, messageId in
      messages.removeAll(where: { $0.id == messageId })
      eventsSubject.send(.messagesDeleted(conversation: conversation, messageIds: [messageId]))
    }
    coreClient.loadLatestMessages = { _, sinceMessageId, _ in
      guard let sinceMessageId else {
        return messages
      }
      return Array(messages.drop(while: { $0.id != sinceMessageId }))
    }
    coreClient.loadMessagesWithIds = { _, ids in
      messages.filter { ids.contains($0.id) }
    }
    coreClient.updateMessage = { conversation, messageId, text in
      guard let idx = messages.firstIndex(where: { $0.id == messageId }) else {
        return
      }
      messages[idx].body = text
      eventsSubject.send(.messagesUpdated(conversation: conversation, messageIds: [messageId]))
    }

    var accountsClient = AccountsClient.noop
    accountsClient.client = { _ in coreClient }

    self.store = Store(
      initialState: .mock(.init(chatId: .johnDoe)),
      reducer: ConversationScreenReducer(),
      prepareDependencies: {
        $0.accountsClient = accountsClient
      }
    )
  }

  var body: some View {
    ConversationScreen(store: self.store)
      .frame(minWidth: 960, minHeight: 320)
  }
}
