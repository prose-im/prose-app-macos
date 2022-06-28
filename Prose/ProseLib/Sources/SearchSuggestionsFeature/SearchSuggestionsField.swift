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
    textField.bezelStyle = .roundedBezel

    return textField
  }

  public func updateNSView(_ textField: NSTextField, context _: Context) {
    textField.stringValue = self.text
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(text: self._text)
  }

  public final class Coordinator: NSObject {
    private static let suggestions = [
      "cram@prose.org",
      "imer@prose.org",
      "marc@prose.org",
      "nairelav@prose.org",
      "remi@prose.org",
      "valerian@prose.org",
    ]

    let text: Binding<String>

    lazy var vc = SuggestionsViewController()
    lazy var window: NSWindow = {
      let window = NSWindow(contentViewController: self.vc)

      let visualEffect = NSVisualEffectView()
      visualEffect.translatesAutoresizingMaskIntoConstraints = false
      visualEffect.material = .hudWindow
      visualEffect.state = .active
      visualEffect.wantsLayer = true
      visualEffect.layer?.cornerRadius = 8

      window.titleVisibility = .hidden
      window.styleMask.remove(.titled)
      window.styleMask.remove(.resizable)
      window.backgroundColor = .clear
      window.isMovableByWindowBackground = true

      let contentView = window.contentView!
      contentView.addSubview(visualEffect, positioned: .below, relativeTo: self.vc.tableView)

      NSLayoutConstraint.activate([
        visualEffect.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        visualEffect.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        visualEffect.topAnchor.constraint(equalTo: contentView.topAnchor),
        visualEffect.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      ])

      return window
    }()

    lazy var wc = SuggestionsWindowController(window: self.window)

    init(text: Binding<String>) {
      self.text = text
    }

    private static func suggestions(for searchString: String) -> [String] {
      if searchString.isEmpty { return [] }
      let results = Self.suggestions.filter { string in
        let options: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
        guard let range = string.range(of: searchString, options: options) else { return false }
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
    textFieldWindow.contentViewController!.addChild(self.vc)
    textFieldWindow.addChildWindow(self.window, ordered: .above)
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

      self.text.wrappedValue = suggestion
      self.wc.orderOut()
      return true
    }

    return false
  }
}
