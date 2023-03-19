//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import ProseCoreFFI

public struct Credentials: Hashable {
  public let jid: BareJid
  public let password: String

  public init(
    jid: BareJid,
    password: String
  ) {
    self.jid = jid
    self.password = password
  }
}
