//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import ProseCoreClientFFI
import ProseCoreTCA

extension XmppMessage {
  static func mock(
    from: BareJid = "jane.doe@prose.org",
    to: BareJid? = nil,
    id: String? = "message-id",
    kind: XmppMessageKind? = nil,
    body: String? = "Empty Message",
    chatState: XmppChatState? = nil,
    replace: String? = nil,
    reactions: XmppMessageReactions? = nil,
    fastening: XmppMessageFastening? = nil,
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
      reactions: reactions,
      fastening: fastening,
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
