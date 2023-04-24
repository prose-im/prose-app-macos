//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import Foundation
import XCTest

final class RosterSelectionTests: XCTestCase {
  override func setUp() {
    self.continueAfterFailure = false
  }

  func testSwitchesConversationWhenSelectingRosterItem() {
    let app = XCUIApplication.launching(testCase: "roster-selection")

    app.sidebar.cells
      .containing(.staticText, identifier: "Oya Karaböcek").element.tap()

    XCTAssertTrue(
      app.chatWebView.staticTexts["Hello from oya.karabocek"]
        .waitForExistence(timeout: 5)
    )

    app.sidebar.cells
      .containing(.staticText, identifier: "Donna Reed").element.tap()

    XCTAssertTrue(
      app.chatWebView.staticTexts["Donna Reed"]
        .waitForExistence(timeout: 5)
    )
  }
}
