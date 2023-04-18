//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import Foundation
import ProseCoreFFI

public struct UserInfo: Equatable {
  public var jid: BareJid
  public var name: String
  public var avatar: URL?

  public init(jid: BareJid, name: String, avatar: URL? = nil) {
    self.jid = jid
    self.name = name
    self.avatar = avatar
  }
}

extension UserInfo: Encodable {}
