//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import SwiftUI

/// Comes from <https://onmyway133.com/posts/how-to-manage-windowgroup-in-swiftui-for-macos/#access-underlying-nswindow>
struct WindowAccessor: NSViewRepresentable {
  @Binding var window: NSWindow?

  func makeNSView(context _: Context) -> NSView {
    let view = NSView()
    DispatchQueue.main.async {
      self.window = view.window
    }
    return view
  }

  func updateNSView(_: NSView, context _: Context) {}
}
