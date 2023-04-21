//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import ProseCoreFFI

extension Contact: Comparable {
  public static func < (lhs: Contact, rhs: Contact) -> Bool {
    switch lhs.name.localizedStandardCompare(rhs.name) {
    case .orderedAscending:
      return true
    case .orderedDescending:
      return false
    case .orderedSame:
      return lhs.jid.rawValue.caseInsensitiveCompare(rhs.jid.rawValue) == .orderedAscending
    }
  }
}
