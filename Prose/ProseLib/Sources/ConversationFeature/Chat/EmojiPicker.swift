//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppKit
import WebKit

final class EmojiPicker: NSTextView {
  lazy var _delegate = EmojiPickerDelegate()

  var onSelection: ((Character?) -> Void)? {
    didSet { self._delegate.onSelection = self.onSelection }
  }

  override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
    super.init(frame: frameRect, textContainer: container)
  }

  init(origin: NSPoint) {
    super.init(frame: NSRect(origin: origin, size: CGSize(width: 1, height: 1)))

    self.textContainerInset = NSSize.zero
    self.textContainer?.lineFragmentPadding = 0
    self.font = .systemFont(ofSize: 1)

    self.delegate = self._delegate

//    #if DEBUG
//    self.backgroundColor = .systemRed
//    #endif
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func accessibilityIsIgnored() -> Bool { true }
}

final class EmojiPickerDelegate: NSObject, NSTextViewDelegate {
  var onSelection: ((Character?) -> Void)?

  func textDidChange(_ notification: Notification) {
    guard let textView = notification.object as? NSTextView else { return }
    self.onSelection?(textView.string.first)
    textView.removeFromSuperview()
  }
}
