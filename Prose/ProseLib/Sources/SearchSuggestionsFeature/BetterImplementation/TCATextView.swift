//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppKit
import ComposableArchitecture
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
      self.viewStore.send(.selectionsDidChange(self.textLayoutManager.textSelections))
      self.isSendingTextChangeToStore = false
    }

    public func textViewDidChangeSelection(_: Notification) {
      guard !self.textViewIsChanging else { return }

      self.viewStore.send(.selectionsDidChange(self.textLayoutManager.textSelections))
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

  case let .selectionsDidChange(selections):
    state.textSelections = selections
    return .none

  case .keyboardEventReceived:
    return .none
  }
}

// MARK: State

/// - Note: The default values replicate the rounded `NSTextField` style.
public struct TCATextViewState: Equatable {
  var text: AttributedString = ""
  var textSelections: [NSTextSelection] = []
  var height: CGFloat = 22
  var borderWidth: CGFloat = 1
  var cornerRadius: CGFloat = 6
  var showFocusRing: Bool = true
}

// MARK: Actions

public enum TCATextViewAction: Equatable {
  case textDidChange(AttributedString)
  case selectionsDidChange([NSTextSelection])
  case keyboardEventReceived(KeyEvent)
}

public enum KeyEvent: Equatable {
  case up
  case down
  case newline
  case escape
}

// MARK: - Previews

struct TCATextView_Previews: PreviewProvider {
  struct Preview: View {
    let store: Store<TCATextView.ViewState, TCATextView.ViewAction>
    var body: some View {
      VStack(alignment: .leading) {
        TCATextView(store: self.store)
        WithViewStore(self.store) { viewStore in
          Text("Text: \"\(NSAttributedString(viewStore.text).string)\"")
          Text(
            "Contains attachments: \(String(describing: NSAttributedString(viewStore.text).containsAttachments))"
          )
          Text(
            "Selections:\n\(viewStore.textSelections.map(Self.selectionDescription(_:)).joined(separator: "\n"))"
          )
        }
      }
      .padding()
      .background(Color.white)
    }

    static func selectionDescription(_ selection: NSTextSelection) -> String {
      "- \(String(describing: selection.textRanges))"
    }
  }

  static var previews: some View {
    Preview(store: Store(
      initialState: TCATextViewState(),
      reducer: textViewReducer,
      environment: ()
    ))
    .frame(width: 300)
    .fixedSize()
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
    .frame(width: 300)
    .fixedSize()
    .previewDisplayName("Squared")
  }
}
