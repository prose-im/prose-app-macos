//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import App
import Foundation

extension AppState {
  /// Returns an `AppState` with jane.doe@prose.org logged in.
  static var authenticated = AppState(
    hasAppearedAtLeastOnce: true,
    main: .init(currentUser: .init(jid: "jane.doe@prose.org"), childState: .init()),
    auth: nil
  )
}
