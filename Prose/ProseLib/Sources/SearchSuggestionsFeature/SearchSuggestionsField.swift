//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import SwiftUI

public struct SearchSuggestionsField: NSViewRepresentable {
  @Binding var text: String

  public init(text: Binding<String>) {
    self._text = text
  }

  public func makeNSView(context: Context) -> NSTextField {
    let textField = NSTextField(frame: .zero)
    textField.delegate = context.coordinator

    return textField
  }

  public func updateNSView(_ textField: NSTextField, context: Context) {
    textField.stringValue = self.text
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(text: self._text)
  }

  public final class Coordinator: NSObject {
    private static let suggestions = ["Al", "Bethany", "Billy", "Bob", "Bobby", "Lucas"]

    let text: Binding<String>

    lazy var suggestionsWindowController = SuggestionsWindowController(owner: self)

    init(text: Binding<String>) {
      self.text = text
    }

    private static func suggestions(for searchString: String) -> [String] {
      if searchString.isEmpty { return [] }
      let results = Self.suggestions.filter { string in
        guard let range = string
          .range(of: searchString, options: [.anchored, .caseInsensitive]) else { return false }
        return !range.isEmpty
      }
      return results
    }
  }
}

extension SearchSuggestionsField.Coordinator: NSTextFieldDelegate {
  // This is just a test, trying to debug what's going on
//  public func controlTextDidBeginEditing(_ notification: Notification) {
//    guard let textField = notification.object as? NSTextField else { return }
//    guard let textFieldWindow: NSWindow = textField.window else {
//      fatalError("`textField` has no `window`")
//    }
//    suggestionsWindowController.awakeFromNib()
//    let window = suggestionsWindowController.window!
//    textFieldWindow.addChildWindow(window, ordered: .above)
////    textFieldWindow.windowController.contentViewController!.addChild(self.suggestionsWindowController.contentViewController!)
//  }

  public func controlTextDidChange(_ notification: Notification) {
    guard let textField = notification.object as? NSTextField else { return }
    self.text.wrappedValue = textField.stringValue

    let filteredSuggestsions = Self.suggestions(for: textField.stringValue)
    self.suggestionsWindowController.showSuggestions(
      filteredSuggestsions,
      for: textField
    )
  }

  public func control(
    _: NSControl,
    textView _: NSTextView,
    doCommandBy commandSelector: Selector
  ) -> Bool {
    if commandSelector == #selector(NSResponder.moveUp(_:)) {
      self.suggestionsWindowController.moveUp()
      return true
    } else if commandSelector == #selector(NSResponder.moveDown(_:)) {
      self.suggestionsWindowController.moveDown()
      return true
    } else if commandSelector == #selector(NSResponder.insertNewline(_:)) {
      guard let suggestion = self.suggestionsWindowController.currentSuggestion else { return false }

//      searchField.stringValue = suggestion
//      resultsLabel.stringValue = suggestion
      self.suggestionsWindowController.orderOut()
      return true
    }

    return false
  }
}
