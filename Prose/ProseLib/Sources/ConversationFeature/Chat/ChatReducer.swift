//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import CoreGraphics
import IdentifiedCollections
import ProseCoreTCA

// MARK: State

struct ChatState: Equatable {
  let loggedInUserJID: JID
  let chatId: JID
  var isWebViewReady = false
  var messages = IdentifiedArrayOf<Message>()
  var selectedMessageId: Message.ID?
  var menu: MessageMenuState?
  var alert: AlertState<ChatAction>?
}

// MARK: Actions

public struct MessageMenuHandlerPayload: Equatable, Decodable {
  struct Point: Equatable, Decodable {
    let x, y: Double
    var cgPoint: CGPoint { CGPoint(x: self.x, y: self.y) }
  }

  let ids: [Message.ID]
  let origin: Point
}

public struct ShowReactionsHandlerPayload: Equatable, Decodable {
  let ids: [Message.ID]
}

public struct ToggleReactionHandlerPayload: Equatable, Decodable {
  let ids: [Message.ID]
  let reaction: String
}

public enum MessageAction: Equatable {
  case showMenu(MessageMenuHandlerPayload)
  case toggleReaction(ToggleReactionHandlerPayload)
  case showReactions(ShowReactionsHandlerPayload)
}

public enum JSEventError: Error, Equatable {
  case badSerialization, decodingError(String)
}

extension JSEventError: CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
    case .badSerialization:
      return "JS message body should be serialized as a String"
    case let .decodingError(debugDescription):
      return debugDescription
    }
  }
}

public enum ChatAction: Equatable {
  case webViewReady, alertDismissed
  case navigateUp, navigateDown
  case messageMenuItemTapped(MessageMenu.Action), menuDidClose
  case message(MessageAction)
  case jsEventError(JSEventError)
}

let chatReducer = Reducer<
  ChatState,
  ChatAction,
  ConversationEnvironment
> { state, action, environment in
  switch action {
  case .webViewReady:
    state.isWebViewReady = true
    return .none

  case .alertDismissed:
    state.alert = nil
    return .none

  case .navigateUp:
    if let messageId = state.selectedMessageId,
       let index = state.messages.index(id: messageId)
    {
      if index > 0 {
        state.selectedMessageId = state.messages[index - 1].id
      } else {
        state.selectedMessageId = nil
      }
    } else {
      state.selectedMessageId = state.messages.last?.id
    }
    return .none

  case .navigateDown:
    if let messageId = state.selectedMessageId,
       let index = state.messages.index(id: messageId)
    {
      if index + 1 < state.messages.count {
        state.selectedMessageId = state.messages[index + 1].id
      } else {
        state.selectedMessageId = nil
      }
    } else {
      state.selectedMessageId = state.messages.first?.id
    }
    return .none

  case .menuDidClose:
    state.menu = nil
    return .none

  case let .messageMenuItemTapped(action):
    switch action {
    case let .copyText(messageId):
      logger.trace("Copying text of \(String(describing: messageId))…")
      if let message = state.messages[id: messageId] {
        environment.pasteboard.copyString(message.body)
      } else {
        logger.notice("Could not copy text: Message \(String(describing: messageId)) not found")
      }

    case let .edit(id):
      logger.trace("Editing \(String(describing: id))…")

    case let .addReaction(id):
      logger.trace("Reacting to \(String(describing: id))…")
      return environment.proseClient.addReaction(state.chatId, id, "👍").fireAndForget()

    case let .remove(id):
      logger.trace("Retracting \(String(describing: id))…")
      return environment.proseClient.retractMessage(state.chatId, id).fireAndForget()
    }
    return .none

  case let .message(.showMenu(payload)):
    logger.trace(
      "Received right click at \(String(describing: payload.origin)) on \(String(describing: payload.ids))"
    )

    let items: [MessageMenuItem]
    if let id: Message.ID = payload.ids.first {
      items = [
        .item(.action(.copyText(id), title: "Copy text")),
        .item(.action(.addReaction(id), title: "Add reaction…")),
        .separator,
        .item(.action(.edit(id), title: "Edit…", isDisabled: true)),
        .item(.action(.remove(id), title: "Remove message", isDisabled: true)),
      ]
    } else {
      items = [.item(.staticText("No action"))]
    }
    var menu = MessageMenuState(ids: payload.ids, origin: payload.origin.cgPoint, items: items)

    let loggedInUserJID: JID = state.loggedInUserJID

    if let messageId = payload.ids.first,
       let message = state.messages[id: messageId],
       message.from == loggedInUserJID
    {
      // TODO: Uncomment once we support message edition
//      menu.updateItem(withTag: .edit) {
//        $0.isDisabled = false
//      }
      menu.updateItem(withTag: .remove) {
        $0.isDisabled = false
      }
    }

    state.menu = menu

    return .none

  case let .message(.showReactions(payload)):
    logger.trace("Showing reactions for \(String(describing: payload.ids))…")

    if let messageId: Message.ID = payload.ids.first {
      #warning("To be replaced")
      return environment.proseClient.addReaction(state.chatId, messageId, "👍").fireAndForget()
    } else {
      logger.notice("Cannot show reactions: No message selected")
    }
    return .none

  case let .message(.toggleReaction(payload)):
    logger.trace("Toggling reaction \(payload.reaction) on \(String(describing: payload.ids))…")

    if let messageId = payload.ids.first {
      return environment.proseClient.toggleReaction(
        state.chatId,
        messageId,
        Reaction(payload.reaction)
      ).fireAndForget()
    } else {
      logger.notice("Could not toggle reaction: No message selected")
      return .none
    }

  case let .jsEventError(error):
    state.alert = AlertState(
      title: TextState(
        verbatim: "An unexpected error occured\nPlease inform us if you encounter this error"
      ),
      message: TextState(verbatim: error.debugDescription)
    )
    return .none
  }
}
