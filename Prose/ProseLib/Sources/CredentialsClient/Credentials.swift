//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import ProseCoreTCA

public struct Credentials: Hashable {
  public let jid: JID
  public let password: String

  public init(
    jid: JID,
    password: String
  ) {
    self.jid = jid
    self.password = password
  }
}
