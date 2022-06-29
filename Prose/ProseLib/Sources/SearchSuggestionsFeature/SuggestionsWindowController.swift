//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Cocoa
import SwiftUI

/// - Copyright: https://github.com/lucasderraugh/AppleProg-Cocoa-Tutorials/tree/master/Lesson%2090
class SuggestionsWindowController<Content: SuggestionsViewProtocol>: NSWindowController {
  weak var vc: SuggestionsViewController<Content>?

  override init(window: NSWindow?) {
    super.init(window: window)
    self.vc = window?.windowController?.contentViewController as? SuggestionsViewController<Content>
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func orderOut() {
    self.window?.orderOut(nil)
  }

  func showSuggestions(for textField: NSTextField) {
    guard let vc = self.vc else { return self.orderOut() }
    if !vc.reload() { return self.orderOut() }

    guard let textFieldWindow = textField.window, let window = self.window else {
      fatalError("`window` is `nil`")
    }
    var textFieldRect = textField.convert(textField.bounds, to: nil)
    textFieldRect = textFieldWindow.convertToScreen(textFieldRect)
    textFieldRect.origin.y -= 1
    window.setFrameTopLeftPoint(textFieldRect.origin)

    var frame = window.frame
    frame.size.width = textField.frame.width + 16
    frame.origin.x -= 8
    window.setFrame(frame, display: false)
    textFieldWindow.addChildWindow(window, ordered: .above)
  }
}
