//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import IdentifiedCollections

public struct Chat {
  public var jid: JID

  /// The number of unread messages in the chat.
  public var numberOfUnreadMessages = 0

  /// The chat states of the participants in the chat, mapped to their JID.
  public var participantStates = [JID: ChatState]()

  /// These will most likely discarded when a chat is closed and will live in the database.
  /// So no outside access.
  internal private(set) var messages = IdentifiedArrayOf<Message>()

  public init(
    jid: JID,
    numberOfUnreadMessages: Int = 0,
    participantStates: [JID: ChatState] = [:]
  ) {
    self.jid = jid
    self.numberOfUnreadMessages = numberOfUnreadMessages
    self.participantStates = participantStates
  }
}

extension Chat: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    // We'll look at the messages separately…
    lhs.numberOfUnreadMessages == rhs.numberOfUnreadMessages &&
      lhs.participantStates == rhs.participantStates
  }
}

extension Chat {
  mutating func appendMessage(_ message: Message) {
    self.messages.append(message)
    if !message.isRead {
      self.numberOfUnreadMessages += 1
    }
  }

  mutating func markMessagesRead() {
    self.messages.ids.forEach { id in
      self.messages[id: id]?.isRead = true
    }
    self.numberOfUnreadMessages = 0
  }

  func containsMessage(id: Message.ID) -> Bool {
    self.messages.ids.contains(id)
  }

  @discardableResult
  mutating func updateMessage(id: Message.ID, with handler: (inout Message) -> Void) -> Bool {
    guard self.messages.ids.contains(id) else {
      return false
    }
    handler(&self.messages[id: id]!)
    return true
  }
}
