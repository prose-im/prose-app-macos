//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import ProseCoreFFI

public extension UserProfile {
  init() {
    self = .init(
      fullName: nil,
      nickname: nil,
      org: nil,
      title: nil,
      email: nil,
      tel: nil,
      url: nil,
      address: nil
    )
  }
}
