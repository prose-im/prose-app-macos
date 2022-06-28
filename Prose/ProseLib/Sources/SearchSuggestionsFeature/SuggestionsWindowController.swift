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

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func windowDidLoad() {
    super.windowDidLoad()

    guard let contentView = window?.contentView else { return }
    guard let tableView = self.vc?.tableView else { return }

//    contentView.addSubview(tableView)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: contentView.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
    ])
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
    textFieldRect.origin.y -= 1
    window.setFrameTopLeftPoint(textFieldRect.origin)

    var frame = window.frame
    frame.size.width = textField.frame.width + 16
    frame.origin.x -= 8
    window.setFrame(frame, display: false)
    textFieldWindow.addChildWindow(window, ordered: .above)

    self.vc?.showSuggestions(suggestions)
  }
}
