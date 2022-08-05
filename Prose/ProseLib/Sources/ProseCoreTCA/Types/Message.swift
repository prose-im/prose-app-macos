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
  init?(message: XmppMessage, timestamp: Date) {
    // We'll discard messages with empty bodies and messages without ids. Ids don't seem to be
    // specified in the XMPP spec but our current server adds them, unless you send a message to
    // yourself.
    guard
      let body = message.body,
      let id = message.id,
      message.fastening == nil
    else {
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
  init(kind: XmppMessageKind) {
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
  var reactions: [Reaction: Set<JID>]

  public init(reactions: [Reaction: Set<JID>] = [:]) {
    self.reactions = reactions
  }

  public mutating func addReaction(_ reaction: Reaction, for jid: JID) {
    self.reactions[reaction, default: Set<JID>()].insert(jid)
  }

  public mutating func toggleReaction(_ reaction: Reaction, for jid: JID) {
    self.reactions.prose_toggle(jid, forKey: reaction)
  }

  public mutating func setReactions(_ reactions: [Reaction], for jid: JID) {
    for (reaction, _) in self.reactions {
      self.reactions[reaction]?.remove(jid)
      if self.reactions[reaction]?.isEmpty == true {
        self.reactions.removeValue(forKey: reaction)
      }
    }
    for reaction in reactions {
      self.reactions[reaction, default: []].insert(jid)
    }
  }

  func reactions(for jid: JID) -> [Reaction] {
    self.reactions.compactMap { reaction, jids in
      jids.contains(jid) ? reaction : nil
    }
  }

  subscript(reaction: Reaction) -> Set<JID>? {
    self.reactions[reaction]
  }
}

extension MessageReactions: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (Reaction, Set<JID>)...) {
    self.init(reactions: Dictionary(uniqueKeysWithValues: elements))
  }
}

struct StringCodingKey: CodingKey {
  let stringValue: String

  init(stringValue: String) {
    self.stringValue = stringValue
  }

  var intValue: Int?

  init?(intValue _: Int) {
    nil
  }
}

extension MessageReactions: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: StringCodingKey.self)

    for (key, value) in self.reactions {
      let jids: [String] = value.map(\.jidString)
      try container.encode(jids, forKey: StringCodingKey(stringValue: key.rawValue))
    }
  }
}
