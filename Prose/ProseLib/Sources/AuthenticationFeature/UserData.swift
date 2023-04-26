//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import Foundation

public struct UserData: Equatable {
  let credentials: Credentials
  var avatar: URL?
  var profile: UserProfile?
}
