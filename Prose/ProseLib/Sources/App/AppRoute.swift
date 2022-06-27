//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AuthenticationFeature
import MainWindowFeature

public enum AppRoute: Equatable {
  case auth(AuthenticationState)
  case main(MainScreenState)
}

public extension AppRoute {
  enum Tag {
    case auth, main
  }

  var tag: Tag {
    switch self {
    case .auth:
      return .auth
    case .main:
      return .main
    }
  }
}
