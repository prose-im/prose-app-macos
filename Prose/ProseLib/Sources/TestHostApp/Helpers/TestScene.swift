//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import SwiftUI

public struct TestScene: Scene {
  public init() {
    if ProcessInfo.processInfo.environment["is-running-ui-test"] == "1" {
      NSScrollView.prose_prepareForUITest()
    }
  }

  public var body: some Scene {
    WindowGroup {
      Group {
        switch ProcessInfo.processInfo.environment["test-case"] {
        case "roster-selection":
          RosterSelection()

        default:
          Text("""
          Missing or unknown test case.

          If you're trying to run a UI Test, make sure to specify the desired testcase in \
          your XCUIApplication with:

          app.launchEnvironment = ["test-case": "roster-selection"]

          If you're trying to run the app manually, add a Environment Variable "test-case" to \
          the current scheme.
          """)
        }
      }
      .ignoresSafeArea()
      .preferredColorScheme(
        ProcessInfo.processInfo.environment["dark-mode-enabled"] == "1" ? .dark : .light
      )
    }
  }
}

private func SwizzleImplementations(
  in obj: AnyClass,
  originalSelector: Selector,
  swizzledSelector: Selector
) {
  if
    let originalMethod = class_getInstanceMethod(obj, originalSelector),
    let swizzledMethod = class_getInstanceMethod(obj, swizzledSelector)
  {
    method_exchangeImplementations(originalMethod, swizzledMethod)
  }
}

extension NSScrollView {
  public static func prose_prepareForUITest() {
    SwizzleImplementations(
      in: NSScrollView.self,
      originalSelector: #selector(flashScrollers),
      swizzledSelector: #selector(prose_flashScrollers)
    )
  }

  @objc func prose_flashScrollers() {
    // Do nothing…
  }
}
