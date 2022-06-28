//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Cocoa

/// - Copyright: https://github.com/lucasderraugh/AppleProg-Cocoa-Tutorials/tree/master/Lesson%2090
class MainWindowController: NSWindowController {
  @IBOutlet private var searchField: NSTextField!
  @IBOutlet private var resultsLabel: NSTextField!

  private let suggestions = ["Al", "Bethany", "Billy", "Bob", "Bobby", "Lucas"]

  lazy var suggestionsWindowController = SuggestionsWindowController()

  convenience init() {
    self.init(windowNibName: String(describing: Self.self))
  }

  private func suggestions(for searchString: String) -> [String] {
    if searchString.isEmpty { return [] }
    let results = self.suggestions.filter { string in
      guard let range = string
        .range(of: searchString, options: [.anchored, .caseInsensitive]) else { return false }
      return !range.isEmpty
    }
    return results
  }
}

extension MainWindowController: NSControlTextEditingDelegate {
  func controlTextDidChange(_: Notification) {
    let filteredSuggestsions = self.suggestions(for: self.searchField.stringValue)
    self.suggestionsWindowController.showSuggestions(
      filteredSuggestsions,
      for: self.searchField
    )
  }

  func control(
    _: NSControl,
    textView _: NSTextView,
    doCommandBy commandSelector: Selector
  ) -> Bool {
    if commandSelector == #selector(moveUp(_:)) {
      suggestionsWindowController.moveUp()
      return true
    }
    if commandSelector == #selector(moveDown(_:)) {
      suggestionsWindowController.moveDown()
      return true
    }
    if commandSelector == #selector(insertNewline(_:)) {
      guard let suggestion = suggestionsWindowController.currentSuggestion
      else { return false }
      searchField.stringValue = suggestion
      resultsLabel.stringValue = suggestion
      suggestionsWindowController.orderOut()
      return true
    }

    return false
  }
}
