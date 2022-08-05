//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import ProseCoreClientFFI
import ProseCoreTCA

extension XmppPresence {
  static func mock(
    kind: XmppPresenceKind? = nil,
    from: BareJid? = "jane.doe@prose.org",
    to: BareJid? = nil,
    show: XmppShowKind? = nil,
    status: String? = nil
  ) -> Self {
    .init(
      kind: kind,
      from: from,
      to: to,
      show: show,
      status: status
    )
  }
}

extension ProseCoreTCA.Presence {
  static func mock(
    kind: ProseCoreTCA.Presence.Kind? = nil,
    show: ProseCoreTCA.Presence.Show? = nil,
    status: String? = nil,
    timestamp: Date = Date()
  ) -> Self {
    .init(kind: kind, show: show, status: status, timestamp: timestamp)
  }
}
