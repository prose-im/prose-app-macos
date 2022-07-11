//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Combine
import ComposableArchitecture
import SwiftUI

// MARK: - View

public struct WithSuggestionsField<SuggestionsView: View>: NSViewRepresentable {
  public typealias ViewState = WithSuggestionsFieldState
  public typealias ViewAction = WithSuggestionsFieldAction

  let store: Store<ViewState, ViewAction>
  let suggestionsView: SuggestionsView

  public init(
    store: Store<ViewState, ViewAction>,
    @ViewBuilder suggestionsView: () -> SuggestionsView
  ) {
    self.store = store
    self.suggestionsView = suggestionsView()
  }

  public func makeNSView(context: Context) -> NSTextView {
    // Create and initialize the supporting layout, container, and storage management.
    let textLayoutManager = NSTextLayoutManager()
    let textContainer = NSTextContainer()
    textLayoutManager.textContainer = textContainer
    let textContentStorage = context.coordinator.viewStore.textContentStorage
    textContentStorage.addTextLayoutManager(textLayoutManager)

    let textView = MyTextView(frame: .zero, textContainer: textLayoutManager.textContainer)

    textView.delegate = context.coordinator

    textView.typingAttributes = defaultTextAttributes

    // Replicate the rounded `NSTextField` style
    textView.wantsLayer = true
    assert(textView.layer != nil)
    textView.layer?.borderWidth = 1
    textView.layer?.borderColor = NSColor.separatorColor.cgColor
    textView.layer?.cornerRadius = 6
    textView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      textView.heightAnchor.constraint(equalToConstant: 22),
    ])

    // Fix the text container inset (sticking at the top by default)
    textView.textContainerInset = NSSize(width: 0, height: 2)

    return textView
  }

  public func updateNSView(_ textView: NSTextView, context: Context) {
    if context.coordinator.viewStore.showSuggestions, textView.window?.firstResponder == textView {
      // Update the window
      context.coordinator.wc.showWindow(self.suggestionsView, on: textView)
    } else {
      context.coordinator.wc.orderOut()
    }
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(
      store: self.store,
      wc: {
        AttachedWindowController(vc: AttachedViewController(content: self.suggestionsView))
      }
    )
  }

  public final class Coordinator: NSObject, NSTextViewDelegate {
    let viewStore: ViewStore<ViewState, ViewAction>

    var isSendingTextChangeToStore = false
    /// We need to send changes of the cursor position as well as any text changes to the ViewStore.
    /// Somehow the UITextViewDelegate receives a call to `textViewDidChangeSelection` before
    /// `textViewDidChange`. Also `textViewDidChangeSelection` is called every time the text changed.
    /// In order to not send duplicate events to the ViewStore but also get the order right (when
    /// the selection changed, we should know the new text already otherwise the indices wouldn't
    /// make sense) we keep track of what's going on.
    var textViewIsChanging = false

    let _wc: () -> AttachedWindowController<SuggestionsView>

    lazy var wc: AttachedWindowController<SuggestionsView> = self._wc()

    init(
      store: Store<ViewState, ViewAction>,
      wc: @escaping () -> AttachedWindowController<SuggestionsView>
    ) {
      self.viewStore = ViewStore(store)
      self._wc = wc
    }

    public func textDidEndEditing(_: Notification) {
      // Hide the popover window when the user focuses another control in the app
      self.wc.orderOut()
    }

    public func textDidChange(_: Notification) {
      self.textViewIsChanging = false

      self.isSendingTextChangeToStore = true
      self.viewStore.send(.textDidChange)
      self.viewStore.send(.textSelectionDidChange)
      self.isSendingTextChangeToStore = false
    }

    public func textViewDidChangeSelection(_: Notification) {
      guard !self.textViewIsChanging else { return }

      self.viewStore.send(.textSelectionDidChange)
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

      self.viewStore.send(.keyboardEventReceived(event))

      // NOTE: We cannot know if the event was handled here… so let's suppose it was.
      return true
    }
  }
}

private final class MyTextView: NSTextView {
  override class var defaultFocusRingType: NSFocusRingType { .exterior }
  override var focusRingMaskBounds: NSRect { self.bounds }

  override func drawFocusRingMask() {
    assert(self.layer != nil)
    if let radius = self.layer?.cornerRadius {
      // Draw the default rounded `NSTextField` focus ring
      NSBezierPath(roundedRect: self.focusRingMaskBounds, xRadius: radius, yRadius: radius).fill()
    } else {
      super.drawFocusRingMask()
    }
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let withSuggestionsFieldReducer = Reducer<
  WithSuggestionsFieldState,
  WithSuggestionsFieldAction,
  Void
>.empty

// MARK: State

public struct WithSuggestionsFieldState: Equatable {
  var textContentStorage: NSTextContentStorage
  var showSuggestions: Bool

  var query: String {
    guard let attributedString: NSAttributedString = self.textContentStorage.attributedString else {
      assertionFailure("`textContentStorage.attributedString` should not be `nil`.")
      return ""
    }

    let queryRange: NSRange = self.textContentStorage.prose_rangeFromLastAttachmentToCaret()
    // NOTE: We could check `queryRange.location != NSNotFound`,
    //       but we can just skip if `queryRange.length == 0`.
    //       This way it's less dependant on the implementation details.
    guard queryRange.length != 0 else { return "" }
    let fullQuery: String = attributedString.attributedSubstring(from: queryRange).string

    return fullQuery.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  func excludedTerms(stringFromAttachment: (NSTextAttachment) -> String?) -> Set<String> {
    var excludedTerms = Set<String>()

    guard let attributedString: NSAttributedString = self.textContentStorage.attributedString else {
      assertionFailure("`textContentStorage.attributedString` should not be `nil`.")
      return excludedTerms
    }

    let range = NSRange(0..<attributedString.length)
    attributedString.enumerateAttribute(.attachment, in: range) { data, _, _ in
      guard let data: Any = data else { return }
      guard let attachment: NSTextAttachment = data as? NSTextAttachment else {
        assertionFailure("`data` is not a `NSTextAttachment`.")
        return
      }
      guard let string: String = stringFromAttachment(attachment) else { return }
      excludedTerms.insert(string)
    }

    return excludedTerms
  }

  public init(
    textContentStorage: NSTextContentStorage = NSTextContentStorage(),
    showSuggestions: Bool = false
  ) {
    self.textContentStorage = textContentStorage
    self.showSuggestions = showSuggestions
  }
}

let defaultTextAttributes: [NSAttributedString.Key: Any] = [
  .font: NSFont.preferredFont(forTextStyle: .body),
  .foregroundColor: NSColor.textColor,
]

// MARK: Actions

public enum WithSuggestionsFieldAction: Equatable {
  /// The user changed the contents of the text field.
  /// - Note: We don't pass any data, as eveything is already contained in
  ///         ``WithSuggestionsFieldState/textContentStorage``.
  case textDidChange

  /// The user changed the selection/insertion position in the text field.
  /// - Note: We don't pass any data, as eveything is already contained in
  ///         ``WithSuggestionsFieldState/textContentStorage``.
  case textSelectionDidChange

  /// We received a keyboard event from AppKit's `textView(_:doCommandBy:) -> Bool`.
  case keyboardEventReceived(SearchSuggestionEvent)
}

public enum SearchSuggestionEvent: Equatable {
  /// The user hit the down arrow key.
  case moveDown
  /// The user hit the up arrow key.
  case moveUp
  /// The user hit the return key.
  case confirmSelection
}
