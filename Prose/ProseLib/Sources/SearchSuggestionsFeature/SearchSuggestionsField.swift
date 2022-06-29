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

public enum SearchSuggestionEventResult: Equatable {
  /// The event was not handled.
  case notHandled
  /// The event was handled, but the window should be kept open.
  case handled
  /// The window should be closed.
  case close

  var handled: Bool { self != .notHandled }
  var orderOut: Bool { self == .close }
}

public protocol SuggestionsViewProtocol: View {
  var shouldBeVisible: Bool { get }
}

public struct SearchSuggestionsField<SuggestionsView: SuggestionsViewProtocol>: NSViewRepresentable {
  @Binding var text: String
  let suggestionsView: () -> SuggestionsView

  let handleKeyboardEvent: (SearchSuggestionEvent) -> SearchSuggestionEventResult

  public init(
    text: Binding<String>,
    handleKeyboardEvent: @escaping (SearchSuggestionEvent) -> SearchSuggestionEventResult = { _ in
      .notHandled
    },
    @ViewBuilder suggestionsView: @escaping () -> SuggestionsView
  ) {
    self._text = text
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

  public func updateNSView(_ textField: NSTextField, context _: Context) {
    // Update the text field text if this update came from SwiftUI
    if textField.stringValue != self.text {
      textField.stringValue = self.text
    }
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(
      text: self._text,
      wc: {
        SuggestionsWindowController(vc: { SuggestionsViewController(content: self.suggestionsView)
        })
      },
      handleKeyboardEvent: self.handleKeyboardEvent
    )
  }

  public final class Coordinator: NSObject, NSTextFieldDelegate {
    let text: Binding<String>

    let handleKeyboardEvent: (SearchSuggestionEvent) -> SearchSuggestionEventResult

    let _wc: () -> SuggestionsWindowController<SuggestionsView>

    lazy var wc: SuggestionsWindowController<SuggestionsView> = self._wc()

    init(
      text: Binding<String>,
      wc: @escaping () -> SuggestionsWindowController<SuggestionsView>,
      handleKeyboardEvent: @escaping (SearchSuggestionEvent) -> SearchSuggestionEventResult
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

      // Show the window if needed
      self.wc.showSuggestions(for: textField)
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

      let res = self.handleKeyboardEvent(event)
      if res.orderOut { self.wc.orderOut() }
      return res.handled
    }
  }
}
