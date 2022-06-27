//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import ProseCoreClientFFI
import ProseCoreTCA

extension ProseCoreClientFFI.Message {
  static func mock(
    from: BareJid = "jane.doe@prose.org",
    to: BareJid? = nil,
    id: String? = "message-id",
    kind: ProseCoreClientFFI.MessageKind? = nil,
    body: String? = "Empty Message",
    chatState: ProseCoreClientFFI.ChatState? = nil,
    replace: String? = nil,
    error: String? = nil
  ) -> Self {
    .init(
      from: from,
      to: to,
      id: id,
      kind: kind,
      body: body,
      chatState: chatState,
      replace: replace,
      error: error
    )
  }
}

extension ProseCoreTCA.Message {
  static func mock(
    from: JID = "jane.doe@prose.org",
    id: ProseCoreTCA.Message.ID = "message-id",
    kind: ProseCoreTCA.MessageKind? = nil,
    body: String = "Empty Message",
    timestamp: Date = .init(),
    isRead: Bool = false,
    isEdited: Bool = false
  ) -> Self {
    .init(
      from: from,
      id: id,
      kind: kind,
      body: body,
      timestamp: timestamp,
      isRead: isRead,
      isEdited: isEdited
    )
  }
}
