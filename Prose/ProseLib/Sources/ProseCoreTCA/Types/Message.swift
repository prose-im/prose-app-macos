//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import ProseCoreClientFFI
import Tagged

public struct Message: Equatable, Identifiable {
  public typealias ID = Tagged<Message, String>

  public var from: JID
  public var id: ID
  public var kind: MessageKind?
  public var body: String
  public var timestamp: Date
  public var isRead: Bool
  public var isEdited: Bool
  public var reactions: MessageReactions

  public init(
    from: JID,
    id: ID,
    kind: MessageKind?,
    body: String,
    timestamp: Date,
    isRead: Bool,
    isEdited: Bool,
    reactions: MessageReactions = .init()
  ) {
    self.from = from
    self.id = id
    self.kind = kind
    self.body = body
    self.timestamp = timestamp
    self.isRead = isRead
    self.isEdited = isEdited
    self.reactions = reactions
  }
}

extension Message {
  init?(message: ProseCoreClientFFI.Message, timestamp: Date) {
    // We'll discard messages with empty bodies and messages without ids. Ids don't seem to be
    // specified in the XMPP spec but our current server adds them, unless you send a message to
    // yourself.
    guard let body = message.body, let id = message.id else {
      return nil
    }

    self.init(
      from: JID(bareJid: message.from),
      id: .init(rawValue: id),
      kind: message.kind.map(MessageKind.init),
      body: body,
      timestamp: timestamp,
      isRead: false,
      isEdited: false
    )
  }
}

public enum MessageKind: Equatable {
  case chat
  case error
  case groupChat
  case headline
  case normal
}

extension MessageKind {
  init(kind: ProseCoreClientFFI.MessageKind) {
    switch kind {
    case .chat:
      self = .chat
    case .error:
      self = .error
    case .groupchat:
      self = .groupChat
    case .headline:
      self = .headline
    case .normal:
      self = .normal
    @unknown default:
      fatalError("Unknown MessageKind \(kind)")
    }
  }
}

public struct MessageReactions: Equatable {
  var reactions: [Character: Set<JID>]

  public init(reactions: [Character: Set<JID>] = [:]) {
    self.reactions = reactions
  }

  public mutating func addReaction(_ reaction: Character, for jid: JID) {
    self.reactions[reaction, default: Set<JID>()].insert(jid)
  }

  public mutating func toggleReaction(_ reaction: Character, for jid: JID) {
    self.reactions.prose_toggle(jid, forKey: reaction)
  }
}

extension MessageReactions: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (Character, Set<JID>)...) {
    self.init(reactions: Dictionary(uniqueKeysWithValues: elements))
  }
}

struct StringCodingKey: CodingKey {
  let stringValue: String

  init(stringValue: String) {
    self.stringValue = stringValue
  }
  init(_ character: Character) {
    self.init(stringValue: String(describing: character))
  }

  var intValue: Int?

  init(intValue: Int) {
    self.init(stringValue: String(describing: intValue))
    // We never want integer keys
//    self.intValue = intValue
  }
}

extension MessageReactions: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: StringCodingKey.self)

    for (key, value) in self.reactions {
      let jids: [String] = value.map(\.jidString)
      try container.encode(jids, forKey: StringCodingKey(key))
    }
  }
}
