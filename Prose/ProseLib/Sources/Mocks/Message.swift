//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation

public extension Message {
  static func mock(
    from: JID = "jane.doe@prose.org",
    id: String = UUID().uuidString,
    kind: MessageKind? = .chat,
    body: String = "Hello World!",
    timestamp: Date = Date(),
    isRead: Bool = false,
    isEdited: Bool = false
  ) -> Self {
    .init(
      from: from,
      id: .init(rawValue: id),
      kind: kind,
      body: body,
      timestamp: timestamp,
      isRead: isRead,
      isEdited: isEdited
    )
  }
}
