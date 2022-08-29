//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppKit
import enum Assets.Colors
import Combine
import ComposableArchitecture
import SwiftUI
import TcaHelpers
import Toolbox

// MARK: - View

public struct TCATextView: View {
  public typealias State = TCATextViewState
  public typealias Action = TCATextViewAction

  private let store: Store<State, Action>

  public init(store: Store<State, Action>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(self.store) { viewStore in
      _TCATextView(store: self.store)
        .overlay(alignment: .topLeading) {
          if let placeholder = viewStore.placeholder, viewStore.isEmpty {
            Text(placeholder)
              .padding(viewStore.textContainerInset.prose_edgeInsets)
              .allowsHitTesting(false)
              .accessibility(hidden: true)
          }
        }
        .accessibility(hint: Text(viewStore.placeholder ?? ""))
        .background {
          ZStack {
            RoundedRectangle(cornerRadius: viewStore.cornerRadius)
              .fill(Color(nsColor: .textBackgroundColor))
            RoundedRectangle(cornerRadius: viewStore.cornerRadius)
              .strokeBorder(Colors.Border.secondary.color, lineWidth: viewStore.borderWidth)
          }
          .ignoresSafeArea(.container, edges: .horizontal)
        }
    }
  }
}

struct _TCATextView: NSViewRepresentable {
  typealias State = TCATextViewState
  typealias Action = TCATextViewAction

  private let store: Store<State, Action>
  @ObservedObject private var viewStore: ViewStore<State, Action>

  init(store: Store<State, Action>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }

  func makeNSView(context: Context) -> MyScrollableTextView {
    let view = MyScrollableTextView(frame: .zero, coordinator: context.coordinator)
    view.textView.textStorage?.setAttributedString(NSAttributedString(self.viewStore.text))
    return view
  }

  func updateNSView(_ view: MyScrollableTextView, context: Context) {
    let textView = view.textView

    let textHasChanged = !context.coordinator.isSendingTextChangeToStore
      && self.viewStore.text != AttributedString(textView.attributedString())
    if textHasChanged {
      // Update the text storage
      assert(textView.textStorage != nil)
      textView.textStorage?.setAttributedString(NSAttributedString(self.viewStore.text))
      if let selection = self.viewStore.selection {
        textView.setSelectedRange(selection, affinity: .upstream, stillSelecting: false)
      }
      // For some reason, the text here is not exactly the same, some attributes change a little.
      // We need to synchronize the state and the view otherwise things break.
      self.viewStore.send(.textDidChange(AttributedString(textView.attributedString())))
    }

    view._updateSize()

    if self.viewStore.isFocused && textView.window?.firstResponder != textView {
      textView.window?.makeFirstResponder(textView)
    } else if !self.viewStore.isFocused && textView.window?.firstResponder == textView {
      textView.window?.resignFirstResponder()
    }

    // Scroll to the caret
    textView.scrollRangeToVisible(textView.selectedRange())
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(store: self.store, viewStore: self.viewStore)
  }

  final class Coordinator: NSObject, NSTextViewDelegate {
    let textContentStorage: NSTextContentStorage
    let textLayoutManager: NSTextLayoutManager

    let store: Store<State, Action>
    let viewStore: ViewStore<State, Action>

    var cancellables = Set<AnyCancellable>()

    var isSendingTextChangeToStore = false
    /// We need to send changes of the cursor position as well as any text changes to the ViewStore.
    /// Somehow the UITextViewDelegate receives a call to `textViewDidChangeSelection` before
    /// `textViewDidChange`. Also `textViewDidChangeSelection` is called every time the text changed.
    /// In order to not send duplicate events to the ViewStore but also get the order right (when
    /// the selection changed, we should know the new text already otherwise the indices wouldn't
    /// make sense) we keep track of what's going on.
    var textViewIsChanging = false

    init(store: Store<State, Action>, viewStore: ViewStore<State, Action>) {
      self.store = store
      self.viewStore = viewStore

      // Create and initialize the supporting layout, container, and storage management.
      self.textLayoutManager = NSTextLayoutManager()
      self.textLayoutManager.usesFontLeading = false
      let textContainer = NSTextContainer()
      self.textLayoutManager.textContainer = textContainer
      self.textContentStorage = NSTextContentStorage()
      self.textContentStorage.addTextLayoutManager(self.textLayoutManager)
    }

    func textDidChange(_: Notification) {
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

    func textViewDidChangeSelection(_: Notification) {
      guard !self.textViewIsChanging else { return }

      let selectionRange: NSRange? = self.textContentStorage.prose_selectionRange()
      self.viewStore.send(.selectionDidChange(selectionRange))
    }

    func textView(
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

      if self.viewStore.interceptedEvents.contains(event) {
        self.viewStore.send(.keyboardEventReceived(event))
        // NOTE: We cannot know if the event was handled here… so let's suppose it was.
        //       This means the user cannot type a new line, even if we don't handle the action.
        //       We could work around this **if needed**.
        return true
      } else {
        return false
      }
    }

    func textViewDidChangeTypingAttributes(_ notification: Notification) {
      guard let textView = notification.object as? MyTextView else {
        assertionFailure("`notification.object` is a `\(type(of: notification.object))`, expected a `MyTextView`")
        return
      }
      let typingAttributes = AttributeContainer(textView.typingAttributes)
      self.viewStore.send(.typingAttributesDidChange(typingAttributes))
    }
  }
}

final class MyScrollableTextView: NSView {
  fileprivate let textView: MyTextView
  var textViewHeightConstraint: NSLayoutConstraint!

  weak var coordinator: _TCATextView.Coordinator?

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

  init(frame frameRect: NSRect, coordinator: _TCATextView.Coordinator) {
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
    let textView = MyTextView(
      frame: .init(origin: .zero, size: frameRect.size),
      textContainer: textContainer
    )
    textView.actions = ViewStore(coordinator.store.stateless)
    textContainer?.size = frameRect.size
    textContainer?.heightTracksTextView = false
    self.textView = textView
    textView.delegate = coordinator
    textView.typingAttributes = coordinator.viewStore.typingAttributes.attributes
    textView.hasFocusRing = coordinator.viewStore.showFocusRing
    textView.drawsBackground = false
    // Remove default 5pt horizontal padding
    textContainer?.lineFragmentPadding = 0
    textView.textContainerInset = coordinator.viewStore.textContainerInset
    // We resize manually
    textView.isHorizontallyResizable = false
    textView.isVerticallyResizable = false

    super.init(frame: frameRect)

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
      scrollView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
      scrollView.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      scrollView.contentView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
    ])

    self.translatesAutoresizingMaskIntoConstraints = false
    let heightConstraint = self.heightAnchor
      .constraint(equalTo: textView.heightAnchor)
    heightConstraint.priority = .defaultHigh
    heightConstraint.isActive = true
    if let minHeight = coordinator.viewStore.minHeight {
      #if DEBUG
        if let maxHeight = coordinator.viewStore.maxHeight {
          assert(minHeight <= maxHeight)
        }
      #endif
      let minHeightConstraint = self.heightAnchor
        .constraint(greaterThanOrEqualToConstant: minHeight)
      minHeightConstraint.priority = .required
      minHeightConstraint.isActive = true
    }
    if let maxHeight = coordinator.viewStore.maxHeight {
      let maxHeightConstraint = self.heightAnchor
        .constraint(lessThanOrEqualToConstant: maxHeight)
      maxHeightConstraint.priority = .required
      maxHeightConstraint.isActive = true
    }
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func resize(withOldSuperviewSize oldSize: NSSize) {
    super.resize(withOldSuperviewSize: oldSize)
    // Allow live resize of the text field
    self._updateSize()
  }

  override func viewDidEndLiveResize() {
    super.viewDidEndLiveResize()
    // FIX: For some reason, when resizing quickly, the last live resize
    //      (`resize(withOldSuperviewSize:)`) doesn't seem to have the correct size.
    //      This ensures the text is correctly laid out after the operation.
    self._updateSize()
    // Scroll to the caret, but not during live resize to avoid weird behaviors
    self.textView.scrollRangeToVisible(self.textView.selectedRange())
  }

  func _updateSize() {
    self._resizeTextContainer()
    let height = self.textContainerHeight
    self.textViewHeightConstraint.constant = height
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
  var actions: ViewStore<Void, TCATextViewAction>!

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

  override func becomeFirstResponder() -> Bool {
    let res = super.becomeFirstResponder()
    if res {
      self.actions.send(.setFocused(true))
    }
    return res
  }

  @discardableResult override func resignFirstResponder() -> Bool {
    let res = super.resignFirstResponder()
    if res {
      self.actions.send(.setFocused(false))
    }
    return res
  }
}

extension EdgeInsets {
  var minHInset: CGFloat { min(self.leading, self.trailing) }
  var minSize: CGSize {
    CGSize(
      width: self.minHInset,
      height: min(self.top, self.bottom)
    )
  }
  /// - NOTE: This cannot be negative.
  var overflowLeading: CGFloat { self.leading - self.minHInset }
  /// - NOTE: This cannot be negative.
  var overflowTrailing: CGFloat { self.trailing - self.minHInset }
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

  case let .typingAttributesDidChange(typingAttributes):
    state.typingAttributes = typingAttributes
    return .none

  case let .setFocused(isFocused):
    state.isFocused = isFocused
    return .none

  case .keyboardEventReceived:
    return .none
  }
}

// MARK: State

public struct TCATextViewState: Equatable {
  static let defaultAttributes = AttributeContainer([
    .font: NSFont.systemFont(ofSize: 12),
    .foregroundColor: NSColor.textColor,
  ])

  public var text: AttributedString
  var placeholder: AttributedString?
  var typingAttributes: AttributeContainer
  var selection: NSRange?
  /// NOTE: [Rémi Bardon] It's not ideal having the sizes here, but I tried using SwiftUI's
  ///       `.frame` modifier, but I couldn't make it work correctly.
  var minHeight, maxHeight: CGFloat?
  var borderWidth: CGFloat
  var cornerRadius: CGFloat
  var textContainerInset: CGSize
  var showFocusRing: Bool
  public var interceptedEvents: Set<KeyEvent>

  public var isFocused: Bool = false

  public var isEmpty: Bool { self.text.characters.isEmpty }

  /// - Note: The default values replicate the rounded `NSTextField` style.
  public init(
    text: AttributedString? = nil,
    placeholder: String? = nil,
    typingAttributes: AttributeContainer? = nil,
    selection: NSRange? = nil,
    minHeight: CGFloat? = nil,
    maxHeight: CGFloat? = nil,
    borderWidth: CGFloat? = nil,
    cornerRadius: CGFloat? = nil,
    textContainerInset: CGSize? = nil,
    showFocusRing: Bool = true,
    interceptEvents: Set<KeyEvent> = []
  ) {
    var typingAttributes = typingAttributes ?? AttributeContainer()
    typingAttributes.merge(Self.defaultAttributes, mergePolicy: .keepCurrent)
    self.text = text ?? AttributedString("", attributes: typingAttributes)
    self.placeholder = Self.placeholder(for: placeholder, typingAttributes: typingAttributes)
    self.typingAttributes = typingAttributes
    self.selection = selection
    self.minHeight = minHeight
    self.maxHeight = maxHeight
    self.borderWidth = borderWidth ?? 1
    self.cornerRadius = cornerRadius ?? 6
    self.textContainerInset = textContainerInset ?? CGSize(width: 5, height: 5)
    self.showFocusRing = showFocusRing
    self.interceptedEvents = interceptEvents
  }

  public init(
    text: String,
    placeholder: String? = nil,
    typingAttributes: AttributeContainer? = nil,
    selection: NSRange? = nil,
    minHeight: CGFloat? = nil,
    maxHeight: CGFloat? = nil,
    borderWidth: CGFloat? = nil,
    cornerRadius: CGFloat? = nil,
    textContainerInset: CGSize? = nil,
    showFocusRing: Bool = true,
    interceptEvents: Set<KeyEvent> = []
  ) {
    self.init(
      text: AttributedString(text, attributes: Self.defaultAttributes),
      placeholder: placeholder,
      typingAttributes: typingAttributes,
      selection: selection,
      minHeight: minHeight,
      maxHeight: maxHeight,
      borderWidth: borderWidth,
      cornerRadius: cornerRadius,
      textContainerInset: textContainerInset,
      showFocusRing: showFocusRing,
      interceptEvents: interceptEvents
    )
  }

  static func placeholder(
    for string: String?,
    typingAttributes: AttributeContainer
  ) -> AttributedString? {
    string.map { string in
      let placeholderAttributes = typingAttributes.merging(AttributeContainer([
        .foregroundColor: NSColor.secondaryLabelColor,
      ]), mergePolicy: .keepNew)
      return AttributedString(string, attributes: placeholderAttributes)
    }
  }

  public mutating func replaceSelection(with string: String, keepSelection: Bool = false) {
    let text = NSMutableAttributedString(self.text)
    let attStr = NSAttributedString(AttributedString(string, attributes: self.typingAttributes))
    if let range = self.selection {
      text.replaceCharacters(in: range, with: attStr)
      if !keepSelection {
        self.selection = NSRange(location: range.location + attStr.length, length: 0)
      }
    } else {
      text.append(attStr)
      if !keepSelection {
        self.selection = NSRange(location: text.length, length: 0)
      }
    }
    self.text = AttributedString(text)
  }

  public mutating func clear() {
    self.text = AttributedString("", attributes: self.typingAttributes)
    self.selection = NSRange(location: 0, length: 0)
  }

  public mutating func setText(to string: String) {
    self.text = AttributedString(string, attributes: self.typingAttributes)
    self.selection = NSRange(location: NSAttributedString(self.text).length, length: 0)
  }

  public mutating func setPlaceholder(to string: String) {
    self.placeholder = Self.placeholder(for: string, typingAttributes: self.typingAttributes)
  }
}

// MARK: Actions

public enum TCATextViewAction: Equatable {
  case textDidChange(AttributedString)
  case selectionDidChange(NSRange?)
  case typingAttributesDidChange(AttributeContainer)
  case keyboardEventReceived(KeyEvent)
  case setFocused(Bool)
}

#if DEBUG

  // MARK: - Previews

  struct TCATextView_Previews: PreviewProvider {
    private struct Preview: View {
      let state: TCATextViewState
      let height: CGFloat?

      init(
        state: TCATextViewState,
        height: CGFloat? = nil
      ) {
        self.state = state
        self.height = height
      }

      var body: some View {
        TCATextView(store: Store(
          initialState: state,
          reducer: textViewReducer,
          environment: ()
        ))
        .frame(width: 500)
        .frame(minHeight: self.height)
        .padding(8)
      }
    }

    static var previews: some View {
      let previews = ScrollView(.vertical) {
        VStack(spacing: 16) {
          GroupBox("Simple message") {
            Preview(state: .init(
              text: "This is a message that was written.",
              placeholder: "Message Valerian",
              interceptEvents: [.newline]
            ))
          }
          GroupBox("Long message") {
            Preview(state: .init(
              text: "This is a \(Array(repeating: "very", count: 20).joined(separator: " ")) long message that was written.",
              placeholder: "Message Valerian",
              interceptEvents: [.newline]
            ))
          }
          GroupBox("Long username") {
            Preview(state: .init(
              placeholder: "Very \(Array(repeating: "very", count: 20).joined(separator: " ")) long placeholder",
              interceptEvents: [.newline]
            ))
          }
          GroupBox("Empty") {
            Preview(state: .init())
          }
          GroupBox("High, multi line") {
            Preview(state: .init(
              placeholder: "Message Valerian",
              minHeight: 128
            ))
          }
          GroupBox("Multi line, small corners") {
            Preview(state: .init(
              placeholder: "Message Valerian",
              cornerRadius: 4
            ))
          }
          GroupBox("Single line vs multi line") {
            VStack(spacing: 0) {
              Preview(state: .init(
                text: "This is a message that was written.",
                placeholder: "Message Valerian"
              ))
              .overlay {
                Preview(state: .init(
                  text: "This is a message that was written.",
                  placeholder: "Message Valerian"
                ))
                .blendMode(.difference)
//                .blendMode(.multiply)
//                .opacity(0.5)
              }
              Preview(state: .init(
                placeholder: "Message Valerian"
              ))
              .overlay {
                Preview(state: .init(
                  placeholder: "Message Valerian"
                ))
//                .blendMode(.difference)
                .blendMode(.multiply)
//                .opacity(0.5)
              }
            }
          }
          GroupBox("Colorful background") {
            Preview(state: .init(
              placeholder: "Message Valerian"
            ))
            .background(Color.pink)
          }
        }
        .padding(8)
      }
      .frame(minHeight: 720)
      previews
        .preferredColorScheme(.light)
        .previewDisplayName("Light")
      previews
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark")
    }
  }
#endif
