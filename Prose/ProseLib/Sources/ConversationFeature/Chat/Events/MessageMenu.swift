//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppKit
import ComposableArchitecture
import ProseCoreTCA
import WebKit

struct MessageMenuHandler: WebMessageHandler {
  struct Body: Decodable {
    let ids: [Message.ID]
    /// - Note: We should write a custom decoder to enforce the fact that this array has two values.
    let origin: [Double]
    var originPoint: CGPoint { CGPoint(x: self.origin[0], y: self.origin[1]) }
  }

  static let jsHandlerName: String = "messageRightClick"
  static let jsEventName: String = "message:actions:view"
  static let jsFunctionName: String = "messageRightClick"

  weak var viewStore: ViewStore<ChatView.State, ChatView.Action>?

  func handle(_ message: WKScriptMessage, body: Body) {
    logger
      .trace(
        "Received right click at \(String(describing: body.originPoint)) on \(String(describing: body.ids))"
      )

    guard let webView = message.webView else {
      logger.fault("`WKScriptMessage` should always be attached to a `WKWebView`")
      return assertionFailure()
    }

    #if os(macOS)
      let menu = MessageMenu(title: "Actions")
      menu.viewStore = self.viewStore

      if let id: Message.ID = body.ids.first {
        menu.addItem(withTitle: "Copy text", action: .copyText(id))
        menu.addItem(withTitle: "Add reaction…", action: .addReaction(id))
        menu.addItem(.separator())
        menu.addItem(withTitle: "Edit…", action: .edit(id), isDisabled: true)
        menu.addItem(withTitle: "Remove message", action: .remove(id), isDisabled: true)
      } else {
        menu.addItem(withTitle: "No action", action: nil)
      }

      // Enable items, which are disabled by default because the responder chain doesn't handle the actions
      menu.autoenablesItems = false

      assert(self.viewStore != nil)
      self.viewStore?.send(.didCreateMenu(menu, for: body.ids))

      menu.popUp(positioning: nil, at: body.originPoint, in: webView)

    #else
      #warning("Show a menu")
      // NOTE: UIKit has [`UIMenuController.showMenu(from:rect:)`](https://developer.apple.com/documentation/uikit/uimenucontroller/3044217-showmenu), but it will be deprecated in iOS 16
    #endif
  }
}

public enum MessageMenuAction: Equatable {
  case copyText(Message.ID)
  case edit(Message.ID)
  case addReaction(Message.ID)
  case remove(Message.ID)

  enum Tag: Int {
    case copyText, edit, addReaction, remove

    var keyEquivalent: String {
      switch self {
      case .copyText: return "c"
      case .edit: return "e"
      case .addReaction: return "r"
      case .remove: return "d"
      }
    }

    var systemImage: String? {
      switch self {
      case .copyText: return "doc.on.clipboard"
      case .edit: return "pencil"
      case .addReaction: return "face.smiling"
      case .remove: return "trash"
      }
    }
  }

  var tag: Tag {
    switch self {
    case .copyText: return .copyText
    case .edit: return .edit
    case .addReaction: return .addReaction
    case .remove: return .remove
    }
  }
}

public final class MessageMenu: NSMenu {
  public typealias Action = MessageMenuAction

  weak var viewStore: ViewStore<ChatView.State, ChatView.Action>?

  func menuItem(
    _ title: String,
    action: Action?,
    isDisabled: Bool = false
  ) -> NSMenuItem {
    let item = NSMenuItem(
      title: title,
      action: #selector(self.itemTapped(_:)),
      keyEquivalent: action?.tag.keyEquivalent ?? ""
    )

    // Set target to receive the events
    item.target = self
    // Store action for later use in handler
    item.representedObject = action
    // Add tag for later insert at index
    item.tag = action?.tag.rawValue ?? -1
    // Disable the item if it does nothing
    item.isEnabled = action != nil && !isDisabled
    // Remove default [.command] modifier
    item.keyEquivalentModifierMask = []
    // Add an optional image
    item.image = action?.tag.systemImage
      .flatMap { NSImage(systemSymbolName: $0, accessibilityDescription: nil) }
    // Set state (on, off, mixed)
//    item.state

    return item
  }

  @discardableResult func addItem(
    withTitle title: String,
    action: Action?,
    isDisabled: Bool = false
  ) -> NSMenuItem {
    let item: NSMenuItem = self.menuItem(title, action: action, isDisabled: isDisabled)
    self.addItem(item)
    return item
  }

  func item(withTag tag: Action.Tag) -> NSMenuItem? {
    self.item(withTag: tag.rawValue)
  }

  @objc func itemTapped(_ sender: Any) {
    guard let viewStore = self.viewStore else {
      logger.fault("`viewStore` is `nil`")
      return assertionFailure()
    }
    guard let menuItem = sender as? NSMenuItem else {
      logger.fault("`sender` has incorrect type")
      return assertionFailure()
    }
    guard let action = menuItem.representedObject as? Action else {
      logger.fault("`menuItem.representedObject` has incorrect type")
      return assertionFailure()
    }

    viewStore.send(.messageMenuItemTapped(action))
  }
}
