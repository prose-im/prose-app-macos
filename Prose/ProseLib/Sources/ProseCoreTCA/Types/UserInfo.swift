//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation

public struct UserInfo: Equatable {
  public var jid: JID
  public var name: String
  public var avatar: URL?

  public init(jid: JID, avatar: URL? = nil) {
    self.jid = jid
    self.name = (jid.bareJid.node ?? jid.bareJid.domain)
      .split(separator: ".", omittingEmptySubsequences: true)
      .joined(separator: " ")
      .localizedCapitalized
    self.avatar = avatar
  }
}

extension UserInfo: Encodable {}
