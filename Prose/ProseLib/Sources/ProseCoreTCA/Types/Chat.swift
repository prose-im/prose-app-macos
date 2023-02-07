//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import IdentifiedCollections
import ProseCore

public struct Chat {
  public var jid: BareJid

  /// The number of unread messages in the chat.
  public var numberOfUnreadMessages = 0

  /// The chat states of the participants in the chat, mapped to their JID.
  public var participantStates = [BareJid: ChatState]()

  /// These will most likely discarded when a chat is closed and will live in the database.
  /// So no outside access.
  internal private(set) var messages = IdentifiedArrayOf<Message>()

  public init(
    jid: BareJid,
    numberOfUnreadMessages: Int = 0,
    participantStates: [BareJid: ChatState] = [:]
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

  /// Replaces the message identified by `message.id` with `message` if a message with `id` exists.
  ///
  /// - Parameters:
  ///   - message: The new message.
  /// - Returns: `true` if a message with `id` existed and was replaced, `false` otherwise.
  /// - SeeAlso: ``updateMessage(id:using:)`` if you need to partially update the message.
  @discardableResult mutating func updateMessage(_ message: Message) -> Bool {
    self.updateMessage(id: message.id, using: { $0 = message })
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
    using handler: (inout Message) throws -> Void
  ) rethrows -> Bool {
    guard var message = self.messages[id: id] else {
      return false
    }
    try handler(&message)
    self.messages[id: id] = message
    return true
  }
}
