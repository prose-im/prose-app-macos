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

    lazy var vc = SuggestionsViewController()
    lazy var window: NSWindow = {
      let window: NSWindow = NSWindow(contentViewController: self.vc)
      window.styleMask.remove(.titled)
      return window
    }()
    lazy var wc = SuggestionsWindowController(window: self.window)

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
  public func controlTextDidBeginEditing(_ notification: Notification) {
    guard let textField = notification.object as? NSTextField else { return }

    guard let textFieldWindow: NSWindow = textField.window else {
      fatalError("`textField` has no `window`")
    }
    textFieldWindow.addChildWindow(self.window, ordered: .above)
    textFieldWindow.contentViewController!.addChild(self.vc)
  }

  public func controlTextDidChange(_ notification: Notification) {
    guard let textField = notification.object as? NSTextField else { return }
    self.text.wrappedValue = textField.stringValue

    let filteredSuggestions = Self.suggestions(for: textField.stringValue)
    self.wc.showSuggestions(
      filteredSuggestions,
      for: textField
    )
  }

  public func control(
    _: NSControl,
    textView _: NSTextView,
    doCommandBy commandSelector: Selector
  ) -> Bool {
    if commandSelector == #selector(NSResponder.moveUp(_:)) {
      self.vc.moveUp()
      return true
    } else if commandSelector == #selector(NSResponder.moveDown(_:)) {
      self.vc.moveDown()
      return true
    } else if commandSelector == #selector(NSResponder.insertNewline(_:)) {
      guard let suggestion = self.vc.currentSuggestion else { return false }

//      searchField.stringValue = suggestion
//      resultsLabel.stringValue = suggestion
      self.wc.orderOut()
      return true
    }

    return false
  }
}
