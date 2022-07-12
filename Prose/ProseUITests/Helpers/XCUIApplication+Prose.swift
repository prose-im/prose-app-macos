//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import XCTest

extension XCUIApplication {
  static func launching(
    testCase: String,
    isDarkModeEnabled: Bool = false,
    animationsEnabled: Bool = false
  ) -> XCUIApplication {
    let app = XCUIApplication()
    app.launchEnvironment = [
      "test-case": testCase,
      "is-running-ui-test": "1",
      "dark-mode-enabled": isDarkModeEnabled ? "1" : "0",
      "animations-enabled": animationsEnabled ? "1" : "0",
    ]
    app.launch()
    return app
  }

  func wait(for seconds: TimeInterval) {
    Thread.sleep(forTimeInterval: seconds)
  }
}

extension XCUIApplication {
  /// Matches content in the left split group.
  var sidebar: XCUIElement {
    self.groups["Sidebar"]
  }

  /// Matches content in the right split group.
  var mainContent: XCUIElement {
    self.groups["MainContent"]
  }

  var chatWebView: XCUIElement {
    self.groups["ChatWebView"].webViews.firstMatch
  }
}
