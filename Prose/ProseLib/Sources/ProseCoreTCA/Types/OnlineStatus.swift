//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

public enum OnlineStatus: Hashable, CaseIterable {
  case offline, online
}

public extension OnlineStatus {
  var localizedDescription: String {
    switch self {
    case .offline:
      return "Offline"
    case .online:
      return "Online"
    }
  }
}

public enum Availability: Hashable, CaseIterable {
  case available, doNotDisturb
}

public extension Availability {
  var localizedDescription: String {
    switch self {
    case .available:
      return "Available for chat"
    case .doNotDisturb:
      return "Do not disturb"
    }
  }
}
