//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import Foundation
import XCTest

final class ConversationInfoTests: XCTestCase {
  override func setUp() {
    self.continueAfterFailure = false
  }

  func testInfoChangesWhenSwitchingConversation() {
    let app = XCUIApplication.launching(testCase: "conversation-info")

    app.sidebar.cells
      .containing(.staticText, identifier: "Oya Karaböcek").element.tap()

    app.toolbars.checkBoxes["Info"].tap()

    XCTAssertTrue(
      app.conversationInfo.otherElements["Oya Karaböcek, available"]
        .waitForExistence(timeout: 5)
    )

    app.sidebar.cells
      .containing(.staticText, identifier: "Donna Reed").element.tap()

    app.toolbars.checkBoxes["Info"].tap()

    XCTAssertTrue(
      app.conversationInfo.otherElements["Donna Reed, available"]
        .waitForExistence(timeout: 5)
    )
  }
}
