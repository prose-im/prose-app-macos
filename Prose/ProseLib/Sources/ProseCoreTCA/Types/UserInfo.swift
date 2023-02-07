//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import ProseCore

public struct UserInfo: Equatable {
  public var jid: BareJid
  public var name: String
  public var avatar: URL?

  public init(jid: BareJid, avatar: URL? = nil) {
    self.jid = jid
    self.name = (jid.node ?? jid.domain)
      .split(separator: ".", omittingEmptySubsequences: true)
      .joined(separator: " ")
      .localizedCapitalized
    self.avatar = avatar
  }
}

extension UserInfo: Encodable {}
