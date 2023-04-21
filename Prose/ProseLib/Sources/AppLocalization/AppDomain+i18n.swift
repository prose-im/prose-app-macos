//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain

public extension Availability {
  var localizedDescription: String {
    switch self {
    case .available:
      return L10n.Availability.available
    case .unavailable:
      return L10n.Availability.unavailable
    case .doNotDisturb:
      return L10n.Availability.doNotDisturb
    case .away:
      return L10n.Availability.away
    }
  }
}
