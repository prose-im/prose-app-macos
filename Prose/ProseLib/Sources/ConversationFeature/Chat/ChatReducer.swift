//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import CoreGraphics
import IdentifiedCollections
import ProseCoreTCA
import ProseUI
import TcaHelpers

// MARK: - State

struct ChatState: Equatable {
  let loggedInUserJID: JID
  let chatId: JID
  var isWebViewReady = false
  var messages = IdentifiedArrayOf<Message>()
  var selectedMessageId: Message.ID?
  var menu: MessageMenuState?
  var reactionPicker: MessageReactionPickerState?
  var alert: AlertState<ChatAction>?
}

struct MessageReactionPickerState: Equatable {
  let messageId: Message.ID
  var pickerState: ReactionPickerState
  let origin: CGPoint
}

// MARK: - Actions

public struct MessageMenuHandlerPayload: Equatable, Decodable {
  struct Point: Equatable, Decodable {
    let x, y: Double
    var cgPoint: CGPoint { CGPoint(x: self.x, y: self.y) }
  }

  let ids: [Message.ID]
  let origin: Point
}

public struct ShowReactionsHandlerPayload: Equatable, Decodable {
  struct Point: Equatable, Decodable {
    let x, y: Double
    var cgPoint: CGPoint { CGPoint(x: self.x, y: self.y) }
  }

  let ids: [Message.ID]
  let origin: Point
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
  case messageMenuItemTapped(MessageMenuAction), menuDidClose
  case message(MessageAction)
  case jsEventError(JSEventError)
  case reactionPicker(ReactionPickerAction), reactionPickerDismissed
}

// MARK: - Reducer

let chatReducer = Reducer<
  ChatState,
  ChatAction,
  ConversationEnvironment
>.combine([
  reactionPickerTogglingReducer._pullback(
    state: OptionalPath(\ChatState.reactionPicker).appending(path: \.pickerState),
    action: CasePath(ChatAction.reactionPicker),
    environment: { _ in () }
  ),
  Reducer { state, action, environment in
    func showReactionPicker(for messageId: Message.ID, origin: CGPoint) {
      let message: Message? = state.messages[id: messageId]
      let selected: [Reaction]? = message?.reactions.reactions(for: state.loggedInUserJID)
      let pickerState = ReactionPickerState(selected: Set(selected ?? []))
      state.reactionPicker = MessageReactionPickerState(
        messageId: messageId,
        pickerState: pickerState,
        origin: origin
      )
    }
    func hideReactionPicker() {
      state.reactionPicker = nil
    }

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

    case let .messageMenuItemTapped(.copyText(messageId)):
      logger.trace("Copying text of \(String(describing: messageId))…")
      if let message = state.messages[id: messageId] {
        environment.pasteboard.copyString(message.body)
      } else {
        logger.notice("Could not copy text: Message \(String(describing: messageId)) not found")
      }
      return .none

    case let .messageMenuItemTapped(.edit(id)):
      logger.trace("Editing \(String(describing: id))…")
      return .none

    case let .messageMenuItemTapped(.addReaction(messageId, origin)):
      logger.trace("Reacting to \(String(describing: messageId))…")
      showReactionPicker(for: messageId, origin: origin)
      return .none

    case let .messageMenuItemTapped(.remove(id)):
      logger.trace("Retracting \(String(describing: id))…")
      return environment.proseClient.retractMessage(state.chatId, id).fireAndForget()

    case let .message(.showMenu(payload)):
      logger.trace(
        "Received right click at \(String(describing: payload.origin)) on \(String(describing: payload.ids))"
      )

      let items: [MessageMenuItem]
      if let id: Message.ID = payload.ids.first {
        items = [
          .item(.action(.copyText(id), title: "Copy text")),
          .item(.action(.addReaction(id, origin: payload.origin.cgPoint), title: "Add reaction…")),
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
//        menu.updateItem(withTag: .edit) {
//          $0.isDisabled = false
//        }
        menu.updateItem(withTag: .remove) {
          $0.isDisabled = false
        }
      }

      state.menu = menu

      return .none

    case let .message(.showReactions(payload)):
      logger.trace("Showing reactions for \(String(describing: payload.ids))…")

      if let messageId: Message.ID = payload.ids.first {
        showReactionPicker(for: messageId, origin: payload.origin.cgPoint)
      } else {
        logger.notice("Cannot show reactions: No message selected")
      }
      return .none

    case let .message(.toggleReaction(payload)):
      logger.trace("Toggling reaction \(payload.reaction) on \(String(describing: payload.ids))…")

      if let messageId = payload.ids.first {
        return environment.proseClient
          .toggleReaction(state.chatId, messageId, Reaction(payload.reaction))
          .fireAndForget()
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

    case let .reactionPicker(.select(reaction)):
      guard let messageId: Message.ID = state.reactionPicker?.messageId else {
        preconditionFailure("We should have stored the message ID")
      }
      return environment.proseClient
        .addReaction(state.chatId, messageId, reaction)
        .fireAndForget()

    case let .reactionPicker(.deselect(reaction)):
      guard let messageId: Message.ID = state.reactionPicker?.messageId else {
        preconditionFailure("We should have stored the message ID")
      }
      let loggedInUserJID = state.loggedInUserJID
      state.messages[id: messageId]?.reactions.toggleReaction(reaction, for: loggedInUserJID)
      return environment.proseClient
        .toggleReaction(state.chatId, messageId, reaction)
        .fireAndForget()

    case .reactionPickerDismissed:
      hideReactionPicker()
      return .none
    }
  },
])
