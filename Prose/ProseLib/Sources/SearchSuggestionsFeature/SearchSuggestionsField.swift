//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import SwiftUI

public enum SearchSuggestionEvent: Equatable {
  case moveDown, moveUp, confirmSelection
}
public enum SearchSuggestionEventResult: Equatable {
  case notHandled, handled, close

  var handled: Bool { self != .notHandled }
  var orderOut: Bool { self == .close }
}

public protocol SuggestionsViewProtocol: View {
  var shouldBeVisible: Bool { get }
}

public struct SearchSuggestionsField<SuggestionsView: SuggestionsViewProtocol>: NSViewRepresentable {
  @Binding var text: String
  let suggestionsView: () -> SuggestionsView

  let handleKeyboardEvent: (SearchSuggestionEvent) -> SearchSuggestionEventResult

  public init(
    text: Binding<String>,
    handleKeyboardEvent: @escaping (SearchSuggestionEvent) -> SearchSuggestionEventResult = { _ in .notHandled },
    @ViewBuilder suggestionsView: @escaping () -> SuggestionsView
  ) {
    self._text = text
    self.suggestionsView = suggestionsView
    self.handleKeyboardEvent = handleKeyboardEvent
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
      handleKeyboardEvent: self.handleKeyboardEvent
    )
  }

  public final class Coordinator: NSObject, NSTextFieldDelegate {
    let text: Binding<String>

    let handleKeyboardEvent: (SearchSuggestionEvent) -> SearchSuggestionEventResult

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

      let contentView = window.contentView!
      contentView.addSubview(visualEffect, positioned: .below, relativeTo: self.vc.hc.view)

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
      handleKeyboardEvent: @escaping (SearchSuggestionEvent) -> SearchSuggestionEventResult
    ) {
      self.text = text
      self._vc = vc
      self.handleKeyboardEvent = handleKeyboardEvent
    }

    public func controlTextDidBeginEditing(_ notification: Notification) {
      guard let textField = notification.object as? NSTextField else { return }

      guard let textFieldWindow: NSWindow = textField.window else {
        fatalError("`textField` has no `window`")
      }
      textFieldWindow.contentViewController!.addChild(self.window.contentViewController!)
      textFieldWindow.addChildWindow(self.window, ordered: .above)

      self.wc.showSuggestions(for: textField)
    }

    public func controlTextDidEndEditing(_: Notification) {
      self.wc.orderOut()
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
      let event: SearchSuggestionEvent
      switch commandSelector {
      case #selector(NSResponder.moveUp(_:)):
        event = .moveUp
      case #selector(NSResponder.moveDown(_:)):
        event = .moveDown
      case #selector(NSResponder.insertNewline(_:)):
        event = .confirmSelection
      default:
        return false
      }

      let res = self.handleKeyboardEvent(event)
      if res.orderOut { self.wc.orderOut() }
      return res.handled
    }
  }
}
