//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import App
import ComposableArchitecture
import Foundation

extension AppEnvironment {
  static var test = AppEnvironment(
    userDefaults: .placeholder,
    credentials: .placeholder,
    proseClient: .noop,
    pasteboard: .noop,
    notifications: .noop,
    mainQueue: .main,
    openURL: { url, _ in
      Effect.fireAndForget {
        logger.info("Not opening url \(url.absoluteString) in UITest.")
      }
    }
  )
}
