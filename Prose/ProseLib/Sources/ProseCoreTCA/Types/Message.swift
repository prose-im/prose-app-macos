//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import ProseCoreClientFFI
import Tagged

public enum MessageKind: Equatable {
  case chat
  case error
  case groupChat
  case headline
  case normal
}

public struct Message: Equatable, Identifiable {
  public typealias ID = Tagged<Message, String>

  public var from: JID
  public var id: ID
  public var kind: MessageKind?
  public var body: String
  public var timestamp: Date
  public var isRead: Bool
  public var isEdited: Bool

  public init(
    from: JID,
    id: ID,
    kind: MessageKind?,
    body: String,
    timestamp: Date,
    isRead: Bool,
    isEdited: Bool
  ) {
    self.from = from
    self.id = id
    self.kind = kind
    self.body = body
    self.timestamp = timestamp
    self.isRead = isRead
    self.isEdited = isEdited
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
