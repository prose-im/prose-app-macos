//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import ProseCoreFFI

extension Message: Identifiable {}

extension Message: Encodable {
  enum CodingKeys: String, CodingKey {
    case id
    case type
    case date
    case content
    case from
    case reactions
    case metas
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
    try container.encode(self.from, forKey: .from)

    do {
      var container = container.nestedContainer(keyedBy: MetaCodingKeys.self, forKey: .metas)
      try container.encode(self.isEdited, forKey: .edited)
      try container.encode(false, forKey: .encrypted)
    }

    try container.encode(self.reactions, forKey: .reactions)
  }
}

extension Reaction: Encodable {
  enum CodingKeys: String, CodingKey {
    case emoji = "reaction"
    case from = "authors"
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.emoji, forKey: .emoji)
    try container.encode(self.from, forKey: .from)
  }
}
