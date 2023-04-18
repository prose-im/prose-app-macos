//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import Foundation
import ProseCoreFFI

public extension FullJid {
  var bareJid: BareJid {
    BareJid(node: self.node, domain: self.domain)
  }
}
