//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppKit
import ComposableArchitecture
import ProseUI
import SwiftUI

// MARK: - View

public struct TCATextView: NSViewRepresentable {
  public typealias ViewState = TCATextViewState
  public typealias ViewAction = TCATextViewAction

  let store: Store<ViewState, ViewAction>

  public init(store: Store<ViewState, ViewAction>) {
    self.store = store
  }

  public func makeNSView(context: Context) -> NSTextView {
    let textContainer: NSTextContainer? = context.coordinator.textLayoutManager.textContainer
    let textView = MyTextView(frame: .zero, textContainer: textContainer)

    textView.delegate = context.coordinator

    textView.typingAttributes = defaultTextAttributes

    textView.wantsLayer = true
    assert(textView.layer != nil)
    textView.layer?.borderWidth = context.coordinator.viewStore.borderWidth
    textView.layer?.borderColor = NSColor.separatorColor.cgColor
    textView.layer?.cornerRadius = context.coordinator.viewStore.cornerRadius
    textView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      textView.heightAnchor.constraint(equalToConstant: context.coordinator.viewStore.height),
    ])

    textView.hasFocusRing = context.coordinator.viewStore.showFocusRing

    // Fix the text container inset (sticking at the top by default)
    textView.textContainerInset = NSSize(width: 0, height: 2)

    return textView
  }

  public func updateNSView(_: NSTextView, context _: Context) {}

  public func makeCoordinator() -> Coordinator {
    Coordinator(store: self.store)
  }

  public final class Coordinator: NSObject, NSTextViewDelegate {
    let textContentStorage: NSTextContentStorage
    let textLayoutManager: NSTextLayoutManager

    let viewStore: ViewStore<ViewState, ViewAction>

    var isSendingTextChangeToStore = false
    /// We need to send changes of the cursor position as well as any text changes to the ViewStore.
    /// Somehow the UITextViewDelegate receives a call to `textViewDidChangeSelection` before
    /// `textViewDidChange`. Also `textViewDidChangeSelection` is called every time the text changed.
    /// In order to not send duplicate events to the ViewStore but also get the order right (when
    /// the selection changed, we should know the new text already otherwise the indices wouldn't
    /// make sense) we keep track of what's going on.
    var textViewIsChanging = false

    init(store: Store<ViewState, ViewAction>) {
      self.viewStore = ViewStore(store)

      // Create and initialize the supporting layout, container, and storage management.
      self.textLayoutManager = NSTextLayoutManager()
      let textContainer = NSTextContainer()
      self.textLayoutManager.textContainer = textContainer
      self.textContentStorage = NSTextContentStorage()
      self.textContentStorage.addTextLayoutManager(self.textLayoutManager)
    }

    public func textDidChange(_: Notification) {
      self.textViewIsChanging = false

      assert(self.textContentStorage.attributedString != nil)
      guard let attributedString: NSAttributedString = self.textContentStorage.attributedString
      else {
        logger.error("\(#function): `textContentStorage.attributedString` is `nil`.")
        return
      }

      self.isSendingTextChangeToStore = true
      assert(self.textContentStorage.attributedString != nil)
      self.viewStore.send(.textDidChange(AttributedString(attributedString)))
      let selectionRange: NSRange? = self.textContentStorage.prose_selectionRange()
      self.viewStore.send(.selectionDidChange(selectionRange))
      self.isSendingTextChangeToStore = false
    }

    public func textViewDidChangeSelection(_: Notification) {
      guard !self.textViewIsChanging else { return }

      let selectionRange: NSRange? = self.textContentStorage.prose_selectionRange()
      self.viewStore.send(.selectionDidChange(selectionRange))
    }

    public func textView(
      _: NSTextView,
      doCommandBy commandSelector: Selector
    ) -> Bool {
      let event: KeyEvent
      switch commandSelector {
      case #selector(NSResponder.moveUp(_:)):
        event = .up
      case #selector(NSResponder.moveDown(_:)):
        event = .down
      case #selector(NSResponder.insertNewline(_:)):
        event = .newline
      default:
        return false
      }

      self.viewStore.send(.keyboardEventReceived(event))

      // NOTE: We cannot know if the event was handled here… so let's suppose it was.
      //       This means the user cannot type a new line, even if we don't handle the action.
      //       We could work around this **if needed**.
      return true
    }
  }
}

private final class MyTextView: NSTextView {
  override class var defaultFocusRingType: NSFocusRingType { .exterior }
  override var focusRingMaskBounds: NSRect { self.bounds }

  var hasFocusRing: Bool = false {
    didSet {
      self.focusRingType = self.hasFocusRing ? Self.defaultFocusRingType : .none
    }
  }

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

public let textViewReducer = Reducer<
  TCATextViewState,
  TCATextViewAction,
  Void
> { state, action, _ in
  switch action {
  case let .textDidChange(text):
    state.text = text
    return .none

  case let .selectionDidChange(range):
    state.selection = range
    return .none

  case .keyboardEventReceived:
    return .none
  }
}

// MARK: State

public struct TCATextViewState: Equatable {
  var text: AttributedString
  var selection: NSRange?
  var height: CGFloat
  var borderWidth: CGFloat
  var cornerRadius: CGFloat
  var showFocusRing: Bool

  /// - Note: The default values replicate the rounded `NSTextField` style.
  public init(
    text: AttributedString = "",
    selection: NSRange? = nil,
    height: CGFloat = 22,
    borderWidth: CGFloat = 1,
    cornerRadius: CGFloat = 6,
    showFocusRing: Bool = true
  ) {
    self.text = text
    self.selection = selection
    self.height = height
    self.borderWidth = borderWidth
    self.cornerRadius = cornerRadius
    self.showFocusRing = showFocusRing
  }
}

// MARK: Actions

public enum TCATextViewAction: Equatable {
  case textDidChange(AttributedString)
  case selectionDidChange(NSRange?)
  case keyboardEventReceived(KeyEvent)
}

// MARK: - Previews

struct TCATextView_Previews: PreviewProvider {
  struct Preview: View {
    let store: Store<TCATextView.ViewState, TCATextView.ViewAction>
    var body: some View {
      VStack(alignment: .leading) {
        TCATextView(store: self.store)
        WithViewStore(self.store) { viewStore in
          let attributedString = NSAttributedString(viewStore.text)

          Text("Text: \"\(attributedString.string)\"")
          Text("Length: \(attributedString.length)")
          Text(
            "Contains attachments: \(String(describing: attributedString.containsAttachments))"
          )

          Text("Selection range: \(String(describing: viewStore.selection))")

          let selectedText: NSAttributedString? = viewStore.selection
            .map(attributedString.attributedSubstring(from:))
          Text("Selected text: \(String(describing: selectedText?.string))")

          let rangeFromLastAttachment: NSRange? = viewStore.selection
            .map(attributedString.prose_rangeFromLastAttachmentToCaret(selectionRange:))
          Text("Range to last attachment: \(String(describing: rangeFromLastAttachment))")

          let textFromLastAttachment: NSAttributedString? = rangeFromLastAttachment
            .map(attributedString.attributedSubstring(from:))
          Text("Text to last attachment: \(String(describing: textFromLastAttachment?.string))")
        }
      }
      .padding()
      .background(Color.white)
      .frame(width: 300)
      .fixedSize()
    }
  }

  static var previews: some View {
    Preview(store: Store(
      initialState: TCATextViewState(),
      reducer: textViewReducer,
      environment: ()
    ))
    .previewDisplayName("Rounded")
    Preview(store: Store(
      initialState: TCATextViewState(
        height: 48,
        borderWidth: 4,
        cornerRadius: 0,
        showFocusRing: false
      ),
      reducer: textViewReducer,
      environment: ()
    ))
    .previewDisplayName("Squared")
  }
}
