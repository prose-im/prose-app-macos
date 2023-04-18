//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_: Notification) {
    NSWindow.allowsAutomaticWindowTabbing = false
  }
}
