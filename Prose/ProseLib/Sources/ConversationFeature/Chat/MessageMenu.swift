//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppKit
import ComposableArchitecture
import ProseBackend
import ProseCoreTCA
import WebKit

public enum MessageMenuAction: Equatable {
  case copyText(Message.ID)
  case edit(Message.ID)
  case addReaction(Message.ID, origin: CGRect)
  case remove(Message.ID)
}

enum MessageMenuItem: Equatable {
  case item(MessageMenuItemState), separator

  var tag: MessageMenuItemState.Tag? {
    switch self {
    case let .item(itemState): return itemState.tag
    case .separator: return nil
    }
  }
}

struct MessageMenuItemState: Equatable {
  enum Tag: Int {
    case copyText, edit, addReaction, remove
  }

  var title: String
  let tag: Tag?
  let action: MessageMenuAction?
  var systemImage: String?
  var isDisabled: Bool

  var isEnabled: Bool { self.action != nil && !self.isDisabled }

  private init(
    title: String,
    tag: Tag? = nil,
    action: MessageMenuAction? = nil,
    systemImage: String? = nil,
    isDisabled: Bool = false
  ) {
    self.title = title
    self.tag = tag
    self.action = action
    self.systemImage = systemImage
    self.isDisabled = isDisabled
  }
}

extension MessageMenuItemState {
  static func action(
    _ action: MessageMenuAction,
    title: String,
    isDisabled: Bool = false
  ) -> Self {
    let tag: Tag = {
      switch action {
      case .copyText: return .copyText
      case .edit: return .edit
      case .addReaction: return .addReaction
      case .remove: return .remove
      }
    }()
    let systemImage: String? = {
      switch tag {
      case .copyText: return "doc.on.clipboard"
      case .edit: return "pencil"
      case .addReaction: return "face.smiling"
      case .remove: return "trash"
      }
    }()

    return MessageMenuItemState(
      title: title,
      tag: tag,
      action: action,
      systemImage: systemImage,
      isDisabled: isDisabled
    )
  }

  static func staticText(_ title: String) -> Self {
    MessageMenuItemState(title: title, isDisabled: true)
  }
}

struct MessageMenuState: Equatable {
  let origin: CGPoint
  var items: [MessageMenuItem]

  @discardableResult mutating func updateItem(
    withTag tag: MessageMenuItemState.Tag,
    update: (inout MessageMenuItemState) -> Void
  ) -> Bool {
    if let index = self.items.firstIndex(where: { $0.tag == tag }),
       case var .item(itemState) = self.items[index]
    {
      update(&itemState)
      self.items[index] = .item(itemState)
      return true
    } else {
      return false
    }
  }
}

public final class MessageMenu: NSMenu {
  public typealias Action = MessageMenuAction

  weak var viewStore: ViewStoreOf<ChatReducer>?

  func createItem(for itemState: MessageMenuItemState) -> NSMenuItem {
    let item = NSMenuItem(
      title: itemState.title,
      action: #selector(self.itemTapped(_:)),
      keyEquivalent: ""
    )

    // Set target to receive the events
    item.target = self
    // Store action for later use in handler
    item.representedObject = itemState.action
    // Add tag for later insert at index
    item.tag = itemState.tag?.rawValue ?? -1
    // Disable the item if it does nothing
    item.isEnabled = itemState.isEnabled
    // Add an optional image
    item.image = itemState.systemImage
      .flatMap { NSImage(systemSymbolName: $0, accessibilityDescription: nil) }
    // Set state (on, off, mixed)
//    item.state

    return item
  }

  @discardableResult func addItem(_ itemState: MessageMenuItemState) -> NSMenuItem {
    let item: NSMenuItem = self.createItem(for: itemState)
    self.addItem(item)
    return item
  }

  func item(withTag tag: MessageMenuItemState.Tag) -> NSMenuItem? {
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
