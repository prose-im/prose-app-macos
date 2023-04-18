//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import Cocoa
import Foundation
import SwiftUI

// This wraps any AppKit (NS[..]) component and transforms it into a SwiftUI-compatible View
extension ViewWrap {
  init(
    _ makeView: @escaping @autoclosure () -> Wrapped,
    updater update: @escaping (Wrapped) -> Void
  ) {
    self.makeView = makeView
    self.update = { view, _ in update(view) }
  }

  init(_ makeView: @escaping @autoclosure () -> Wrapped) {
    self.makeView = makeView
    self.update = { _, _ in }
  }
}

struct ViewWrap<Wrapped: NSView>: NSViewRepresentable {
  typealias Updater = (Wrapped, Context) -> Void

  var makeView: () -> Wrapped
  var update: (Wrapped, Context) -> Void

  init(
    _ makeView: @escaping @autoclosure () -> Wrapped,
    updater update: @escaping Updater
  ) {
    self.makeView = makeView
    self.update = update
  }

  func makeNSView(context _: Context) -> Wrapped {
    self.makeView()
  }

  func updateNSView(_ view: Wrapped, context: Context) {
    self.update(view, context)
  }
}
