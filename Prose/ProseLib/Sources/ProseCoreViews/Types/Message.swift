//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import ProseCoreTCA

public struct Message: Equatable, Encodable, Identifiable {
  public struct User: Equatable, Encodable {
    public let jid: String
    public let name: String
  }

  public struct Reaction: Equatable, Encodable {
    public let reaction: String
    public let authors: [String]
  }

  fileprivate static var dateFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions.insert(.withFractionalSeconds)
    return formatter
  }()

  public let id: ProseCoreTCA.Message.ID
  public let type = "text"
  public let date: String
  public let content: String
  public let from: User
  public let reactions: [Reaction]

  public init(from message: ProseCoreTCA.Message) {
    self.id = message.id
    self.date = Self.dateFormatter.string(from: message.timestamp)
    self.content = message.body
    self.from = User(
      jid: message.from.jidString,
      name: message.from.jidString
    )
    self.reactions = message.reactions.reactions.map(Reaction.init(from:))
  }
}

extension Message.Reaction {
  init(from element: MessageReactions.WrappedValue.Element) {
    self.init(reaction: element.key.rawValue, authors: element.value.map(\.rawValue))
  }
}
