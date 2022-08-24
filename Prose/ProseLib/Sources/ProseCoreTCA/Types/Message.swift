//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import OrderedCollections
import ProseCoreClientFFI
import Tagged

// MARK: - Message

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

extension Message: Encodable {
  enum CodingKeys: String, CodingKey {
    case id, type, date, content, from, reactions, metas
  }

  enum UserCodingKeys: String, CodingKey {
    case jid, name
  }

  enum MetaCodingKeys: String, CodingKey {
    case encrypted, edited
  }

  fileprivate static var dateFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions.insert(.withFractionalSeconds)
    return formatter
  }()

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(self.id, forKey: .id)
    try container.encode("text", forKey: .type)
    try container.encode(Self.dateFormatter.string(from: self.timestamp), forKey: .date)
    try container.encode(self.body, forKey: .content)
    do {
      var container = container.nestedContainer(keyedBy: UserCodingKeys.self, forKey: .from)
      try container.encode(self.from, forKey: .jid)
      // FIXME: Find a way to set `name` to the correct value
      try container.encode(String(describing: self.from), forKey: .name)
    }

    do {
      var container = container.nestedContainer(keyedBy: MetaCodingKeys.self, forKey: .metas)
      try container.encode(self.isEdited, forKey: .edited)
      try container.encode(false, forKey: .encrypted)
    }

    try container.encode(self.reactions, forKey: .reactions)
  }
}

// MARK: - MessageKind

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

// MARK: - MessageReactions

public struct MessageReactions: Equatable {
  public typealias WrappedValue = OrderedDictionary<Reaction, OrderedSet<JID>>

  public private(set) var reactions: WrappedValue

  public init(reactions: WrappedValue = [:]) {
    self.reactions = reactions
  }

  public mutating func addReaction(_ reaction: Reaction, for jid: JID) {
    self.reactions[reaction, default: OrderedSet<JID>()].append(jid)
  }

  public mutating func toggleReaction(_ reaction: Reaction, for jid: JID) {
    self.reactions.prose_toggle(jid, forKey: reaction)
  }

  public mutating func setReactions(_ reactions: [Reaction], for jid: JID) {
    let updatedReactions = Set(reactions)

    for reaction in self.reactions.keys where !updatedReactions.contains(reaction) {
      self.reactions[reaction]?.remove(jid)
      // Remove key if the set is now empty
      if self.reactions[reaction]?.isEmpty == true {
        self.reactions.removeValue(forKey: reaction)
      }
    }
    for reaction in reactions {
      self.reactions[reaction, default: []].append(jid)
    }
  }

  public func reactions(for jid: JID) -> [Reaction] {
    self.reactions.compactMap { reaction, jids in
      jids.contains(jid) ? reaction : nil
    }
  }

  subscript(reaction: Reaction) -> OrderedSet<JID>? {
    self.reactions[reaction]
  }
}

extension MessageReactions: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (Reaction, OrderedSet<JID>)...) {
    self.init(reactions: OrderedDictionary(uniqueKeysWithValues: elements))
  }
}

extension MessageReactions: Encodable {
  enum CodingKeys: String, CodingKey {
    case reaction, authors
  }

  public func encode(to encoder: Encoder) throws {
    var arrayContainer = encoder.unkeyedContainer()

    for (key, value) in self.reactions where !value.isEmpty {
      var container = arrayContainer.nestedContainer(keyedBy: CodingKeys.self)
      try container.encode(key, forKey: .reaction)
      try container.encode(value.map(\.jidString), forKey: .authors)
    }
  }
}

extension MessageReactions: CustomDebugStringConvertible {
  public var debugDescription: String {
    var lines = [String]()
    for (reaction, authors) in self.reactions {
      lines.append("\(reaction): [\(authors.map(\.rawValue).joined(separator: ","))]")
    }
    return "[\(lines.joined(separator: ","))]"
  }
}
