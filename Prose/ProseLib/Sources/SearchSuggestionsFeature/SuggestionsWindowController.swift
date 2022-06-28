//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Cocoa

/// - Copyright: https://github.com/lucasderraugh/AppleProg-Cocoa-Tutorials/tree/master/Lesson%2090
class SuggestionsWindowController: NSWindowController {
  weak var vc: SuggestionsViewController?

  override init(window: NSWindow?) {
    super.init(window: window)
    self.vc = window?.windowController?.contentViewController as? SuggestionsViewController
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func orderOut() {
    self.vc?.tableView.deselectAll(nil)
    self.window?.orderOut(nil)
  }

  func showSuggestions(_ suggestions: [String], for textField: NSTextField) {
    guard !suggestions.isEmpty else { return self.orderOut() }

    guard let textFieldWindow = textField.window, let window = self.window else {
      fatalError("`window` is `nil`")
    }
    var textFieldRect = textField.convert(textField.bounds, to: nil)
    textFieldRect = textFieldWindow.convertToScreen(textFieldRect)
    textFieldRect.origin.y -= 5
    window.setFrameTopLeftPoint(textFieldRect.origin)

    var frame = window.frame
    frame.size.width = textField.frame.width
    window.setFrame(frame, display: false)
    textFieldWindow.addChildWindow(window, ordered: .above)

    self.vc?.showSuggestions(suggestions)
  }
}
