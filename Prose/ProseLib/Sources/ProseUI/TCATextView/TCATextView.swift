//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppKit
import Combine
import ComposableArchitecture
import SwiftUI
import Toolbox

// MARK: - View

public struct TCATextView: NSViewRepresentable {
  public typealias ViewState = TCATextViewState
  public typealias ViewAction = TCATextViewAction

  private let store: Store<ViewState, ViewAction>
  @ObservedObject private var viewStore: ViewStore<ViewState, ViewAction>

  public init(store: Store<ViewState, ViewAction>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }

  public func makeNSView(context: Context) -> MyScrollableTextView {
    let view = MyScrollableTextView(frame: .zero, coordinator: context.coordinator)
    view.textView.textStorage?.setAttributedString(NSAttributedString(self.viewStore.text))
    return view
  }

  public func updateNSView(_ view: MyScrollableTextView, context: Context) {
    let textView = view.textView

    let textHasChanged = !context.coordinator.isSendingTextChangeToStore
      && self.viewStore.text != AttributedString(textView.attributedString())
    if textHasChanged {
      logger.debug("Updating text…")
      // Update the text storage
      assert(textView.textStorage != nil)
      textView.textStorage?.setAttributedString(NSAttributedString(self.viewStore.text))
    }

    view._updateSize()

    // Scroll to the caret
    textView.scrollRangeToVisible(textView.selectedRange())
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(viewStore: self.viewStore)
  }

  public final class Coordinator: NSObject, NSTextViewDelegate {
    let textContentStorage: NSTextContentStorage
    let textLayoutManager: NSTextLayoutManager

    let viewStore: ViewStore<ViewState, ViewAction>

    var cancellables = Set<AnyCancellable>()

    var isSendingTextChangeToStore = false
    /// We need to send changes of the cursor position as well as any text changes to the ViewStore.
    /// Somehow the UITextViewDelegate receives a call to `textViewDidChangeSelection` before
    /// `textViewDidChange`. Also `textViewDidChangeSelection` is called every time the text changed.
    /// In order to not send duplicate events to the ViewStore but also get the order right (when
    /// the selection changed, we should know the new text already otherwise the indices wouldn't
    /// make sense) we keep track of what's going on.
    var textViewIsChanging = false

    init(viewStore: ViewStore<ViewState, ViewAction>) {
      self.viewStore = viewStore

      // Create and initialize the supporting layout, container, and storage management.
      self.textLayoutManager = NSTextLayoutManager()
      self.textLayoutManager.usesFontLeading = false
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
      return false

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

public final class MyScrollableTextView: NSView {
  fileprivate let textView: MyTextView
  var textViewHeightConstraint: NSLayoutConstraint!

  weak var coordinator: TCATextView.Coordinator?

  var textContainerHeight: CGFloat {
    guard let coordinator = self.coordinator else {
      assertionFailure("`self.coordinator` is `nil`")
      return self.textView.frame.height
    }
    guard let textContainer = coordinator.textLayoutManager.textContainer else {
      assertionFailure("`textLayoutManager.textContainer` is `nil`")
      return self.textView.frame.height
    }

    let string = self.textView.attributedString()
    let bounds = string.boundingRect(with: textContainer.size, options: [.usesLineFragmentOrigin])

    let height = bounds.height + coordinator.viewStore.textContainerInset.height * 2
    return height
  }

  init(frame frameRect: NSRect, coordinator: TCATextView.Coordinator) {
    self.coordinator = coordinator

    // Create scroll view

    let scrollView = NSTextView.scrollableTextView()
    scrollView.drawsBackground = false
    scrollView.hasVerticalScroller = true
    scrollView.hasHorizontalScroller = false
    scrollView.autohidesScrollers = true
    scrollView.verticalScrollElasticity = .none

    // Create text view

    let textContainer: NSTextContainer? = coordinator.textLayoutManager.textContainer
    assert(textContainer != nil)
    let textView = MyTextView(frame: .zero, textContainer: textContainer)
    self.textView = textView
    textView.delegate = coordinator
    textView.typingAttributes = coordinator.viewStore.typingAttributes.attributes
    textView.hasFocusRing = coordinator.viewStore.showFocusRing
    // Remove default 5pt horizontal padding
    textContainer?.lineFragmentPadding = 0
    textView.textContainerInset = coordinator.viewStore.textContainerInset
    textView.isHorizontallyResizable = true

    super.init(frame: frameRect)

    // Create border

    self.wantsLayer = true
    assert(self.layer != nil)
    self.layer?.borderWidth = coordinator.viewStore.borderWidth
    self.layer?.borderColor = NSColor.separatorColor.cgColor
    self.layer?.cornerRadius = coordinator.viewStore.cornerRadius

    // Add views

    textView.viewWillMove(toSuperview: scrollView.documentView)
    assert(textView.enclosingScrollView == nil)
    scrollView.documentView = textView
    assert(textView.enclosingScrollView != nil)
    textView.viewDidMoveToSuperview()
    self.addSubview(scrollView)

    // Add constraints

    let height = self.textContainerHeight
    self.textViewHeightConstraint = textView.heightAnchor
      .constraint(equalToConstant: height)
    self.textViewHeightConstraint.priority = .defaultHigh
    textView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      textView.topAnchor.constraint(equalTo: scrollView.contentView.topAnchor),
      textView.bottomAnchor.constraint(equalTo: scrollView.contentView.bottomAnchor),
      textView.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor),
      textView.trailingAnchor.constraint(equalTo: scrollView.contentView.trailingAnchor),
      self.textViewHeightConstraint,
    ])

    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.contentView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: self.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      scrollView.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      scrollView.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
    ])

    let heightConstraint = self.heightAnchor.constraint(equalTo: textView.heightAnchor)
    heightConstraint.priority = .defaultHigh
    let maxHeightConstraint = self.heightAnchor.constraint(lessThanOrEqualToConstant: 128)
    maxHeightConstraint.priority = .required
    self.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      heightConstraint,
      maxHeightConstraint,
    ])
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func resize(withOldSuperviewSize oldSize: NSSize) {
    super.resize(withOldSuperviewSize: oldSize)
    // Allow live resize of the text field
    self._updateSize()
  }

  override public func viewDidEndLiveResize() {
    super.viewDidEndLiveResize()
    // FIX: For some reason, when resizing quickly, the last live resize
    //      (`resize(withOldSuperviewSize:)`) doesn't seem to have the correct size.
    //      This ensures the text is correctly laid out after the operation.
    self._updateSize()
    // Scroll to the caret, but not during live resize to avoid weird behaviors
    self.textView.scrollRangeToVisible(self.textView.selectedRange())
  }

  func _updateSize() {
    let height = self.textContainerHeight
    self.textViewHeightConstraint.constant = height
    self._resizeTextContainer()
    // Make sure we layout the text again
    // FIX: This fixes the text not appearing sometimes after an insert from `updateNSView`
    if let textLayoutManager = self.textView.textLayoutManager {
      textLayoutManager.invalidateLayout(for: textLayoutManager.documentRange)
    }
  }

  func _resizeTextContainer() {
    // Update the container width and let it resize vertically
    let width = self.frame.width - self.textView.textContainerInset.width * 2
    self.textView.textContainer?.size.width = width
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
  public var text: AttributedString
  var typingAttributes: AttributeContainer
  var selection: NSRange?
  var height: CGFloat
  var borderWidth: CGFloat
  var cornerRadius: CGFloat
  var textContainerInset: NSSize
  var showFocusRing: Bool

  /// - Note: The default values replicate the rounded `NSTextField` style.
  public init(
    text: AttributedString? = nil,
    typingAttributes: AttributeContainer? = nil,
    selection: NSRange? = nil,
    height: CGFloat = 24,
    borderWidth: CGFloat = 1,
    cornerRadius: CGFloat = 6,
    textContainerInset: NSSize = NSSize(width: 5, height: 5),
    showFocusRing: Bool = true
  ) {
    var typingAttributes = typingAttributes ?? AttributeContainer()
    typingAttributes.merge(AttributeContainer([
      .foregroundColor: NSColor.textColor,
    ]), mergePolicy: .keepCurrent)
    self.text = text ?? AttributedString("", attributes: typingAttributes)
    self.typingAttributes = typingAttributes
    self.selection = selection
    self.height = height
    self.borderWidth = borderWidth
    self.cornerRadius = cornerRadius
    self.textContainerInset = textContainerInset
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
      HStack(alignment: .top) {
        TCATextView(store: self.store)
        WithViewStore(self.store) { viewStore in
          VStack(alignment: .leading) {
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

//          let rangeFromLastAttachment: NSRange? = viewStore.selection
//            .map(attributedString.prose_rangeFromLastAttachmentToCaret(selectionRange:))
//          Text("Range to last attachment: \(String(describing: rangeFromLastAttachment))")

//          let textFromLastAttachment: NSAttributedString? = rangeFromLastAttachment
//            .map(attributedString.attributedSubstring(from:))
//          Text("Text to last attachment: \(String(describing: textFromLastAttachment?.string))")
          }
        }
        .frame(maxHeight: .infinity, alignment: .top)
      }
      .padding()
      .background(Color(nsColor: .textBackgroundColor))
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
    .previewDisplayName("Default")
    Preview(store: Store(
      initialState: TCATextViewState(
        height: 24,
        cornerRadius: 12,
        textContainerInset: NSSize(width: 8, height: 5),
        showFocusRing: false
      ),
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
