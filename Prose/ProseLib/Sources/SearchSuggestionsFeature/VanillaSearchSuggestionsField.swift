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

let vanillaSearchSuggestionsFieldDefaultTextAttributes: [NSAttributedString.Key: Any] = [
  .font: NSFont.preferredFont(forTextStyle: .body),
  .foregroundColor: NSColor.textColor,
]

public struct VanillaSearchSuggestionsField<SuggestionsView: View>: NSViewRepresentable {
  @Binding var text: AttributedString
  let showSuggestions: Bool
  let suggestionsView: () -> SuggestionsView

  let handleKeyboardEvent: (SearchSuggestionEvent) -> Bool

  public init(
    text: Binding<AttributedString>,
    showSuggestions: Bool,
    handleKeyboardEvent: @escaping (SearchSuggestionEvent) -> Bool = { _ in false },
    @ViewBuilder suggestionsView: @escaping () -> SuggestionsView
  ) {
    self._text = text
    self.showSuggestions = showSuggestions
    self.suggestionsView = suggestionsView
    self.handleKeyboardEvent = handleKeyboardEvent
  }

  public func makeNSView(context: Context) -> NSTextView {
    let textView = MyTextView(frame: .zero)
    textView.delegate = context.coordinator

    textView.textStorage?.setAttributedString(NSAttributedString(self.text))
    textView.typingAttributes = vanillaSearchSuggestionsFieldDefaultTextAttributes

    // Make text field rounded
//    textView.bezelStyle = .squareBezel
//    textView.controlSize = .large

    // Allow display of attachments
//    textView.allowsEditingTextAttributes = true

    textView.wantsLayer = true
    textView.layer!.borderWidth = 1
    textView.layer!.borderColor = NSColor.separatorColor.cgColor
    textView.layer!.cornerRadius = 6

    textView.textContainerInset = NSSize(width: 0, height: 2)

    textView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      textView.heightAnchor.constraint(equalToConstant: 22),
    ])

    return textView
  }

  public func updateNSView(_ textView: NSTextView, context: Context) {
//    var attrs: [AttributedString.Key: Any] = [:]
//    attrs[.foregroundColor] = NSColor.red
    // NOTE: [Rémi Bardon] I really don't think this is good, this should use the TextKit 2 APIs
//    let range = NSMakeRange(0, textView.textStorage!.characters.count)
//    textView.textStorage!.addAttributes(attrs, range: range)

    // Update the text field text if this update came from SwiftUI
    if AttributedString(textView.attributedString()) != self.text {
      textView.textStorage?.setAttributedString(NSAttributedString(self.text))
      textView.typingAttributes = vanillaSearchSuggestionsFieldDefaultTextAttributes
    }

    if self.showSuggestions, textView.window?.firstResponder == textView {
      // Update the window
      context.coordinator.wc.showSuggestions(self.suggestionsView, on: textView)
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

  public final class Coordinator: NSObject, NSTextViewDelegate {
    let text: Binding<AttributedString>

    let handleKeyboardEvent: (SearchSuggestionEvent) -> Bool

    let _wc: () -> SuggestionsWindowController<SuggestionsView>

    lazy var wc: SuggestionsWindowController<SuggestionsView> = self._wc()

    init(
      text: Binding<AttributedString>,
      wc: @escaping () -> SuggestionsWindowController<SuggestionsView>,
      handleKeyboardEvent: @escaping (SearchSuggestionEvent) -> Bool
    ) {
      self.text = text
      self._wc = wc
      self.handleKeyboardEvent = handleKeyboardEvent
    }

    public func textDidEndEditing(_: Notification) {
      // Hide the popover window when the user focuses another control in the app
      self.wc.orderOut()
    }

    public func textDidChange(_ notification: Notification) {
      guard let textView = notification.object as? NSTextView else {
        fatalError()
      }

      // Send the text update to SwiftUI
      self.text.wrappedValue = AttributedString(textView.attributedString())
    }

    public func textView(
      _: NSTextView,
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

final class MyTextView: NSTextView {

  override class var defaultFocusRingType: NSFocusRingType { .exterior }
  override var focusRingMaskBounds: NSRect { self.bounds }

  override func drawFocusRingMask() {
    if let radius = self.layer?.cornerRadius {
      NSBezierPath(roundedRect: self.focusRingMaskBounds, xRadius: radius, yRadius: radius).fill()
    } else {
      super.drawFocusRingMask()
    }
  }

}
