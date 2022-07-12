//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import App
import Foundation

extension AppState {
  /// Returns an `AppState` with jane.doe@prose.org logged in.
  static var authenticated = AppState(
    hasAppearedAtLeastOnce: true,
    main: .init(jid: "jane.doe@prose.org"),
    auth: nil
  )
}
