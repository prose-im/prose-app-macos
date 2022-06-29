//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import SwiftUI

public struct SearchSuggestionsField<SuggestionsView: View>: NSViewRepresentable {
  @Binding var text: String
  let suggestionsView: () -> SuggestionsView

  let moveUp: () -> Bool
  let moveDown: () -> Bool
  let select: () -> (Bool, Bool)

  public init(
    text: Binding<String>,
    @ViewBuilder suggestionsView: @escaping () -> SuggestionsView,
    moveUp: @escaping () -> Bool,
    moveDown: @escaping () -> Bool,
    select: @escaping () -> (Bool, Bool)
  ) {
    self._text = text
    self.suggestionsView = suggestionsView
    self.moveUp = moveUp
    self.moveDown = moveDown
    self.select = select
  }

  public func makeNSView(context: Context) -> NSTextField {
    let textField = NSTextField(frame: .zero)
    textField.delegate = context.coordinator
    textField.bezelStyle = .roundedBezel

    return textField
  }

  public func updateNSView(_ textField: NSTextField, context _: Context) {
    textField.stringValue = self.text
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(
      text: self._text,
      vc: { SuggestionsViewController(content: self.suggestionsView) },
      moveUp: self.moveUp,
      moveDown: self.moveDown,
      select: self.select
    )
  }

  public final class Coordinator: NSObject, NSTextFieldDelegate {
    let text: Binding<String>

    let moveUp: () -> Bool
    let moveDown: () -> Bool
    let select: () -> (Bool, Bool)

    let _vc: () -> SuggestionsViewController<SuggestionsView>

    lazy var vc = _vc()
    lazy var window: NSWindow = {
      let window = NSWindow(contentViewController: self.vc)

      let visualEffect = NSVisualEffectView()
      visualEffect.translatesAutoresizingMaskIntoConstraints = false
      visualEffect.material = .hudWindow
      visualEffect.state = .active
      visualEffect.wantsLayer = true
      visualEffect.layer?.cornerRadius = 8

      window.titleVisibility = .hidden
      window.styleMask.remove(.titled)
      window.styleMask.remove(.resizable)
      window.backgroundColor = .clear
      window.isMovableByWindowBackground = true

      let contentView = window.contentView!
      contentView.addSubview(visualEffect, positioned: .below, relativeTo: self.vc.hostingView)

      NSLayoutConstraint.activate([
        visualEffect.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        visualEffect.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        visualEffect.topAnchor.constraint(equalTo: contentView.topAnchor),
        visualEffect.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      ])

      return window
    }()

    lazy var wc = SuggestionsWindowController<SuggestionsView>(window: self.window)

    init(
      text: Binding<String>,
      vc: @escaping () -> SuggestionsViewController<SuggestionsView>,
      moveUp: @escaping () -> Bool,
      moveDown: @escaping () -> Bool,
      select: @escaping () -> (Bool, Bool)
    ) {
      self.text = text
      self._vc = vc
      self.moveUp = moveUp
      self.moveDown = moveDown
      self.select = select
    }

    public func controlTextDidBeginEditing(_ notification: Notification) {
      guard let textField = notification.object as? NSTextField else { return }

      guard let textFieldWindow: NSWindow = textField.window else {
        fatalError("`textField` has no `window`")
      }
      textFieldWindow.contentViewController!.addChild(self.window.contentViewController!)
      textFieldWindow.addChildWindow(self.window, ordered: .above)
    }

    public func controlTextDidChange(_ notification: Notification) {
      guard let textField = notification.object as? NSTextField else { return }
      self.text.wrappedValue = textField.stringValue

      self.wc.showSuggestions(for: textField)
    }

    public func control(
      _: NSControl,
      textView _: NSTextView,
      doCommandBy commandSelector: Selector
    ) -> Bool {
      if commandSelector == #selector(NSResponder.moveUp(_:)) {
        return self.moveUp()
      } else if commandSelector == #selector(NSResponder.moveDown(_:)) {
        return self.moveDown()
      } else if commandSelector == #selector(NSResponder.insertNewline(_:)) {
        let (handled, orderOut) = self.select()
        if orderOut { self.wc.orderOut() }
        return handled
      }

      return false
    }
  }
}
