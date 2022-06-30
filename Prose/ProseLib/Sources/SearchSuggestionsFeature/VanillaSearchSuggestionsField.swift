//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import SwiftUI

public enum SearchSuggestionEvent: Equatable {
  /// The user hit the down arrow key.
  case moveDown
  /// The user hit the up arrow key.
  case moveUp
  /// The user hit the return key.
  case confirmSelection
}

public struct VanillaSearchSuggestionsField<SuggestionsView: View>: NSViewRepresentable {
  @Binding var text: String
  let showSuggestions: Bool
  let suggestionsView: () -> SuggestionsView

  let handleKeyboardEvent: (SearchSuggestionEvent) -> Bool

  public init(
    text: Binding<String>,
    showSuggestions: Bool,
    handleKeyboardEvent: @escaping (SearchSuggestionEvent) -> Bool = { _ in false },
    @ViewBuilder suggestionsView: @escaping () -> SuggestionsView
  ) {
    self._text = text
    self.showSuggestions = showSuggestions
    self.suggestionsView = suggestionsView
    self.handleKeyboardEvent = handleKeyboardEvent
  }

  public func makeNSView(context: Context) -> NSTextField {
    let textField = NSTextField(frame: .zero)
    textField.delegate = context.coordinator

    // Make text field rounded
    textField.bezelStyle = .roundedBezel

    return textField
  }

  public func updateNSView(_ textField: NSTextField, context: Context) {
    // Update the text field text if this update came from SwiftUI
    if textField.stringValue != self.text {
      textField.stringValue = self.text
    }

    if self.showSuggestions, textField.currentEditor() != nil {
      // Update the window
      context.coordinator.wc.showSuggestions(self.suggestionsView, on: textField)
    } else {
      context.coordinator.wc.orderOut()
    }
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(
      text: self._text,
      wc: {
        SuggestionsWindowController(vc: SuggestionsViewController(content: self.suggestionsView))
      },
      handleKeyboardEvent: self.handleKeyboardEvent
    )
  }

  public final class Coordinator: NSObject, NSTextFieldDelegate {
    let text: Binding<String>

    let handleKeyboardEvent: (SearchSuggestionEvent) -> Bool

    let _wc: () -> SuggestionsWindowController<SuggestionsView>

    lazy var wc: SuggestionsWindowController<SuggestionsView> = self._wc()

    init(
      text: Binding<String>,
      wc: @escaping () -> SuggestionsWindowController<SuggestionsView>,
      handleKeyboardEvent: @escaping (SearchSuggestionEvent) -> Bool
    ) {
      self.text = text
      self._wc = wc
      self.handleKeyboardEvent = handleKeyboardEvent
    }

    public func controlTextDidEndEditing(_: Notification) {
      // Hide the popover window when the user focuses another control in the app
      self.wc.orderOut()
    }

    public func controlTextDidChange(_ notification: Notification) {
      guard let textField = notification.object as? NSTextField else { return }

      // Send the text update to SwiftUI
      self.text.wrappedValue = textField.stringValue
    }

    public func control(
      _: NSControl,
      textView _: NSTextView,
      doCommandBy commandSelector: Selector
    ) -> Bool {
      let event: SearchSuggestionEvent
      switch commandSelector {
      case #selector(NSResponder.moveUp(_:)):
        event = .moveUp
      case #selector(NSResponder.moveDown(_:)):
        event = .moveDown
      case #selector(NSResponder.insertNewline(_:)):
        event = .confirmSelection
      default:
        return false
      }

      return self.handleKeyboardEvent(event)
    }
  }
}
