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

  mutating func removeMessage(id: Message.ID) {
    if self.messages.remove(id: id)?.isRead == false {
      self.numberOfUnreadMessages -= 1
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

  /// Replaces the message identified by `id` with `message` if a message with `id` exists. Use
  /// this method instead of ``updateMessage(id:with:)`` if the identity of `message` is different
  /// from the one being replaced.
  ///
  /// - Parameters:
  ///   - id: The id of the message to replace.
  ///   - message: The replacement for the message.
  /// - Returns: `true` if a message with `id` existed and was replaced, `false` otherwise.
  @discardableResult mutating func replaceMessage(id: Message.ID, with message: Message) -> Bool {
    guard let idx = self.messages.index(id: id) else {
      return false
    }
    self.messages.remove(at: idx)
    self.messages.insert(message, at: idx)
    return true
  }

  /// Transforms message identified by `id` using `handler` in a transactional manner. If `handler`
  /// throws, the message will not be updated.
  ///
  /// - Parameters:
  ///   - id: The id of the message to update.
  ///   - handler: The handler used to transform the message.
  /// - Returns: `true` if message with id exists, `false` otherwise.
  @discardableResult mutating func updateMessage(
    id: Message.ID,
    with handler: (inout Message) throws -> Void
  ) rethrows -> Bool {
    guard var message = self.messages[id: id] else {
      return false
    }
    try handler(&message)
    self.messages[id: id] = message
    return true
  }
}
