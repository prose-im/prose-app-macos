//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppKit
import SwiftUI

final class SuggestionsViewController<Content: View>: NSViewController {
  var content: () -> Content

  lazy var hostingView = NSHostingView(rootView: content())

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

    self.view.addSubview(self.hostingView)
    self.hostingView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      self.hostingView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.hostingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.hostingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      self.hostingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
//      self.hostingView.heightAnchor.constraint(greaterThanOrEqualToConstant: 64),
    ])
  }

  func reload() {
    self.hostingView.rootView = self.content()
  }
}
