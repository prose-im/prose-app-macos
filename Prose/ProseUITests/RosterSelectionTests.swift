//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import XCTest

final class RosterSelectionTests: XCTestCase {
  func testSwitchesConversationWhenSelectingRosterItem() {
    let app = XCUIApplication.launching(testCase: "roster-selection")

    app.sidebar.outlineRows
      .containing(.staticText, identifier: "oya.karabocek@example.com").element.tap()

    XCTAssertTrue(
      app.chatWebView.staticTexts["Hello from oya.karabocek"]
        .waitForExistence(timeout: 1)
    )

    app.sidebar.outlineRows
      .containing(.staticText, identifier: "donna.reed@example.com").element.tap()

    XCTAssertTrue(
      app.chatWebView.staticTexts["donna.reed@example.com"]
        .waitForExistence(timeout: 1)
    )
  }
}
