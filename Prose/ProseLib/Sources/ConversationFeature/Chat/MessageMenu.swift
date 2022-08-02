//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppKit
import ComposableArchitecture
import ProseCoreTCA
import WebKit

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

struct MessageMenuState: Equatable {
  let ids: [Message.ID]
  let origin: CGPoint
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
