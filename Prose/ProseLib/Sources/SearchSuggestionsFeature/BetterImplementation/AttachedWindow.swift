//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Combine
import ComposableArchitecture
import SwiftUI

public extension View {
  func attachedWindow<Content: View>(
    isPresented: Bool,
    @ViewBuilder content: () -> Content
  ) -> some View {
    AttachedWindow(root: self, content: content, showWindow: isPresented)
  }
}

private struct AttachedWindow<Root: View, Content: View>: NSViewRepresentable {
  let root: Root
  let content: Content
  let showWindow: Bool

  public init(
    root: Root,
    @ViewBuilder content: () -> Content,
    showWindow: Bool
  ) {
    self.root = root
    self.content = content()
    self.showWindow = showWindow
  }

  public func makeNSView(context _: Context) -> NSHostingView<Root> {
    let view = NSHostingView(rootView: self.root)

    // Prevent the view from filling up the whole screen
    view.translatesAutoresizingMaskIntoConstraints = false

    return view
  }

  public func updateNSView(_ view: NSHostingView<Root>, context: Context) {
    view.rootView = self.root
    view.invalidateIntrinsicContentSize()

    DispatchQueue.main.async {
      if self.showWindow {
        context.coordinator.wc.showWindow(self.content, on: view)
      } else {
        context.coordinator.wc.orderOut()
      }
    }
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(
      wc: { AttachedWindowController(vc: AttachedViewController(content: self.content)) }
    )
  }

  public final class Coordinator: NSObject {
    let _wc: () -> AttachedWindowController<Content>

    lazy var wc: AttachedWindowController<Content> = self._wc()

    init(wc: @escaping () -> AttachedWindowController<Content>) {
      self._wc = wc
    }
  }
}
