//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppKit
import ComposableArchitecture
import ProseCoreTCA
import WebKit

public struct EmojiPickerState: Equatable {
  let origin: CGPoint
}

public enum EmojiPickerAction: Equatable {
  case willAppear, willDisappear
  case didSelect(Character?)
}

final class EmojiPickerView: NSView {
  var viewStore: ViewStore<EmojiPickerState, EmojiPickerAction>

  init(viewStore: ViewStore<EmojiPickerState, EmojiPickerAction>) {
    self.viewStore = viewStore
    #if DEBUG
      let size = CGSize(width: 1, height: 1)
//      let size = CGSize(width: 10, height: 10)
    #else
      let size = CGSize(width: 1, height: 1)
    #endif
    super.init(frame: NSRect(origin: viewStore.state.origin, size: size))

    self.wantsLayer = true
    assert(self.layer != nil)
    self.layer?.backgroundColor = NSColor.systemRed.cgColor
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension EmojiPickerView {
  override var acceptsFirstResponder: Bool { true }

  override func becomeFirstResponder() -> Bool {
    #if DEBUG
      assert(self.layer != nil)
      self.layer?.backgroundColor = NSColor.systemGreen.cgColor
    #endif

    self.viewStore.send(.willAppear)

    return super.becomeFirstResponder()
  }

  @discardableResult override func resignFirstResponder() -> Bool {
    #if DEBUG
      assert(self.layer != nil)
      self.layer?.backgroundColor = NSColor.systemGray.cgColor
    #endif

    // NOTE: This small delay is here because when clicking a button on screen
    //       to show the emoji picker, the picker is first dismissed, because a click
    //       was made outside, and then the button click event is received.
    //       In order to handle the event properly (i.e. if we don't want to show the picker again),
    //       we need to receive the dismiss event after the button click event.
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
      self.viewStore.send(.willDisappear)
    }

    return super.resignFirstResponder()
  }

  override func removeFromSuperview() {
    #if DEBUG
      assert(self.layer != nil)
      self.layer?.backgroundColor = NSColor.systemPurple.cgColor
    #endif
    super.removeFromSuperview()
  }
}

extension EmojiPickerView: NSTextInputClient {
  func insertText(_ string: Any, replacementRange _: NSRange) {
    // This method is called when the user selects an emoji
    if let string = string as? String {
      self.viewStore.send(.didSelect(string.first))
    }
  }

  func setMarkedText(_: Any, selectedRange _: NSRange, replacementRange _: NSRange) {}

  func unmarkText() {}

  func selectedRange() -> NSRange { NSRange(location: 0, length: 0) }

  func markedRange() -> NSRange { NSRange(location: NSNotFound, length: 0) }

  func hasMarkedText() -> Bool { false }

  func attributedSubstring(
    forProposedRange _: NSRange,
    actualRange _: NSRangePointer?
  ) -> NSAttributedString? {
    nil
  }

  func validAttributesForMarkedText() -> [NSAttributedString.Key] { [] }

  func firstRect(forCharacterRange _: NSRange, actualRange _: NSRangePointer?) -> NSRect {
    // The emoji picker uses the returned rect to position itself
    var rect = self.bounds
    rect.origin.x = rect.midX
    rect.size.width = 0
    return self.window!.convertToScreen(self.convert(rect, to: nil))
  }

  func characterIndex(for _: NSPoint) -> Int { 0 }
}
