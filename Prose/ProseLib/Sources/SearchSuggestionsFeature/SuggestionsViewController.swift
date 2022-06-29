//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppKit
import SwiftUI

final class SuggestionsViewController<Content: SuggestionsViewProtocol>: NSViewController {
  var content: () -> Content

  lazy var hc = NSHostingController(rootView: self.content())

  init(content: @escaping () -> Content) {
    self.content = content
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    // Set `self.view` so AppKit doesn't try to load a `nib` file
    self.view = NSView()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Add the hosted view
    self.addChild(self.hc)
    self.view.addSubview(self.hc.view)

    // Make sure the hosted view always fills the full view
    self.hc.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      self.hc.view.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.hc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.hc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      self.hc.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
    ])
  }
}
