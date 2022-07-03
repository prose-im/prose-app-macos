//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Cocoa
import SwiftUI

class SuggestionsWindowController<Content: View>: NSWindowController {
  let vc: SuggestionsViewController<Content>

  init(vc: SuggestionsViewController<Content>) {
    self.vc = vc

    let window = NSWindow(contentViewController: vc)

    // Remove the title bar
    window.styleMask.remove(.titled)
    // Disable window resizing
    window.styleMask.remove(.resizable)
    // Remove the default background
    window.backgroundColor = .clear

    let background = NSVisualEffectView()
    // Set the background to the system material used for HUDs
    background.material = .hudWindow
    // Activate the effect
    background.state = .active
    // Allow corner clipping (otherwise the radius won't apply)
    background.wantsLayer = true
    // Set the corner radius
    background.layer?.cornerRadius = 8

    let contentView = window.contentView!
    // Add the background under the hosted view
    contentView.addSubview(background, positioned: .below, relativeTo: vc.hc.view)

    // Make sure the background always fills the full view
    background.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      background.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      background.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      background.topAnchor.constraint(equalTo: contentView.topAnchor),
      background.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
    ])

    super.init(window: window)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func orderOut() {
    if let window = self.window, window.isVisible {
      window.orderOut(self)
      logger.trace("Window removed from screen")
    }
  }

  func showSuggestions(_ suggestionsView: () -> Content, on view: NSView) {
    // Fail gracefully if we cannot show the window
    guard let viewWindow = view.window else {
      return logger.error("`view` has no `window`")
    }
    guard let window = self.window else {
      return logger.error("`window` is `nil`")
    }

    // Show the window if needed
    if !window.isVisible {
      // Move the window under the text field
      var viewRect = view.convert(view.bounds, to: nil)
      viewRect = viewWindow.convertToScreen(viewRect)
      window.setFrameTopLeftPoint(viewRect.origin)

      // Make the window a little bigger than the text field
      var frame = window.frame
      frame.size.width = view.frame.width + 16
      frame.origin.x -= 8
      window.setFrame(frame, display: false)

      // Add the window on screen
      viewWindow.addChildWindow(window, ordered: .above)

      logger.trace("Window added on screen")
    }

    // Update the view
    self.vc.hc.rootView = suggestionsView()
  }
}
