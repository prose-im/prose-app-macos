//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import Foundation

public extension Message {
  static func mock(
    id: MessageId = .init(UUID().uuidString),
    from: BareJid = "jane.doe@prose.org",
    body: String = "Hello World!",
    timestamp: Date = Date(),
    isRead: Bool = false,
    isEdited: Bool = false,
    isDelivered: Bool = false,
    reactions: [Reaction] = []
  ) -> Self {
    .init(
      id: id,
      stanzaId: "stanza-id",
      from: from,
      body: body,
      timestamp: timestamp,
      isRead: isRead,
      isEdited: isEdited,
      isDelivered: isDelivered,
      reactions: reactions
    )
  }
}
