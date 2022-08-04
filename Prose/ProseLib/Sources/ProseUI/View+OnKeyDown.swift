//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Carbon.HIToolbox
import SwiftUI

public enum KeyEvent: Equatable {
  case up
  case down
  case newline
  case escape
}

private struct KeyAwareView<Content: View>: NSViewRepresentable {
  let rootView: Content
  let onEvent: (KeyEvent) -> Void

  func makeNSView(context _: Context) -> KeyView<Content> {
    let view = KeyView(rootView: self.rootView)
    view.onEvent = self.onEvent
    // NOTE: [Rémi Bardon] This doesn't seem useful for our current use case, but we will probably need it
    //       if we use `.onKeyDown` on a "regular" View.
    //    DispatchQueue.main.async {
    //      view.window?.makeFirstResponder(view)
    //    }
    return view
  }

  func updateNSView(_ view: KeyView<Content>, context _: Context) {
    view.rootView = self.rootView
  }
}

private class KeyView<Content: View>: NSHostingView<Content> {
  var onEvent: (KeyEvent) -> Void = { _ in }

  override var acceptsFirstResponder: Bool { true }

  /// - Note: Codes come from <https://github.com/sindresorhus/KeyboardShortcuts/blob/0994810987dba8783274f2b5c2a407a4d4dea8c8/Sources/KeyboardShortcuts/Key.swift>.
  override func keyDown(with event: NSEvent) {
    switch Int(event.keyCode) {
    case kVK_UpArrow:
      self.onEvent(.up)
    case kVK_DownArrow:
      self.onEvent(.down)
    case kVK_Return:
      self.onEvent(.newline)
    case kVK_Escape:
      self.onEvent(.escape)
    default:
      super.keyDown(with: event)
    }
  }
}

public extension View {
  /// - Copyright: Inspired by [How to handle keyDown in SwiftUI for macOS](https://onmyway133.com/posts/how-to-handle-keydown-in-swiftui-for-macos/)
  ///              and [Handle Keyboard Presses Using SwiftUI in macOS](https://www.swiftjectivec.com/handling-keyboard-presses-in-swiftui-for-macos/).
  /// - Note: Do not use `self.background(KeyAwareView(onEvent: onEvent))`, which breaks the responder chain
  ///         if `self` can become first responder. By having ``KeyAwareView`` as a wrapper around `self`,
  ///         we ensure ``KeyAwareView`` stays first responder as long as we need it to, and it correctly
  ///         receives the key events.
  func onKeyDown(perform onEvent: @escaping (KeyEvent) -> Void) -> some View {
    KeyAwareView(rootView: self, onEvent: onEvent).accessibilityElement(children: .contain)
  }

  func onKeyDown(_ key: KeyEvent, perform onEvent: @escaping () -> Void) -> some View {
    self.onKeyDown { keyEvent in
      if keyEvent == key {
        onEvent()
      }
    }
  }
}
