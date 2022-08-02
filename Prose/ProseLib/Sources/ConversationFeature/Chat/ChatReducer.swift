//
//  File.swift
//  
//
//  Created by Rémi Bardon on 02/08/2022.
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

public enum ChatAction: Equatable {
  case webViewReady
  case navigateUp, navigateDown
  case didCreateMenu(MessageMenu, for: [Message.ID]), menuDidClose
  case messageMenuItemTapped(MessageMenu.Action)
  case message(MessageAction)
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

  case let .didCreateMenu(menu, messageIds):
    let loggedInUserJID: JID = state.loggedInUserJID

    if let messageId = messageIds.first,
       let message = state.messages[id: messageId],
       message.from == loggedInUserJID
    {
      return .fireAndForget {
        // TODO: Uncomment once we support message edition
        //        menu.item(withTag: .edit)!.isEnabled = true
        menu.item(withTag: .remove)!.isEnabled = true
      }
      .receive(on: environment.mainQueue)
      .eraseToEffect()
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
      // NOTE: No need to `state.messages.removeAll(where:)` because the view will be automatically updated
      return environment.proseClient.retractMessage(id).fireAndForget()
    }
    return .none

  case let .message(.showMenu(payload)):
    logger.trace(
      "Received right click at \(String(describing: payload.origin)) on \(String(describing: payload.ids))"
    )
    state.menu = MessageMenuState(ids: payload.ids, origin: payload.origin.cgPoint)
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

    guard let reaction = payload.reaction.first else { return .none }

    if let messageId = payload.ids.first {
      return environment.proseClient.toggleReaction(state.chatId, messageId, reaction).fireAndForget()
    } else {
      logger.notice("Could not toggle reaction: No message selected")
      return .none
    }
  }
}
