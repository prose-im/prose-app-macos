//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

public enum ChatID: Hashable {
  case person(id: JID)
  case group(id: JID)

  public var jid: JID {
    switch self {
    case let .person(id: jid),
         let .group(id: jid):
      return jid
    }
  }
}
