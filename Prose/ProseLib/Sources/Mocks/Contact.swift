//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import Foundation

public extension Contact {
  static func mock(
    jid: BareJid = "user@prose.org",
    name: String = "Prose User",
    avatar: URL? = nil,
    availability: Availability = .unavailable,
    status: String? = nil,
    groups: [String] = []
  ) -> Self {
    .init(
      jid: jid,
      name: name,
      avatar: avatar,
      availability: availability,
      status: status,
      groups: groups
    )
  }
}

public extension Contact {
  static let johnDoe = Contact.mock(
    jid: "john.doe@prose.org",
    name: "John Doe"
  )
}
