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
    self.view = NSView()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.hc.rootView = self.content()
    self.addChild(self.hc)

    self.view.addSubview(self.hc.view)
    self.hc.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      self.hc.view.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.hc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.hc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      self.hc.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
//      self.hc.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 64),
    ])
  }

  func reload() -> Bool {
    let content = self.content()
    self.hc.rootView = content
    return content.shouldBeVisible
  }
}
