//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import Foundation
import ProseBackend
import ProseCoreViews
import ProseUI
import Toolbox

public struct ChatReducer: ReducerProtocol {
  public typealias State = ChatSessionState<ChatState>

  public struct ChatState: Equatable {
    var isWebViewReady = false
    var messages = IdentifiedArrayOf<ProseBackend.Message>()
    var selectedMessageId: ProseBackend.Message.ID?
    var menu: MessageMenuState?
    var reactionPicker: MessageReactionPickerState?
    var messageEditor: EditMessageReducer.EditMessageState?
    var alert: AlertState<Action>?
  }

  public enum Action: Equatable {
    case webViewReady
    case alertDismissed
    case navigateUp
    case navigateDown
    case messageMenuItemTapped(MessageMenuAction)
    case menuDidClose
    case message(MessageEvent)
    case jsEventError(JSEventError)
    case reactionPicker(ReactionPickerReducer.Action)
    case reactionPickerDismissed
    case messageEditor(EditMessageReducer.Action)
    case messageEditorDismissed
    case editMessageResult(Result<None, EquatableError>)
  }

  public init() {}

  @Dependency(\.mainQueue) var mainQueue

  public var body: some ReducerProtocol<State, Action> {
    #warning("Enable Reducers")
//    reactionPickerTogglingReducer._pullback(
//    state: OptionalPath(\ChatSessionState<ChatState>.reactionPicker).appending(path: \.pickerState),
//    action: CasePath(ChatAction.reactionPicker),
//    environment: { _ in () }
//  ),
//  editMessageReducer.optional().pullback(
//    state: \.messageEditor,
//    action: CasePath(ChatAction.messageEditor),
//    environment: { $0 }
//  ),

    self.core
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      func showReactionPicker(for messageId: ProseBackend.Message.ID, origin: CGRect) {
        let message = state.messages[id: messageId]
        #warning("FIXME")
        // let selected = message?.reactions.reactions(for: state.currentUser)
        // let pickerState = ReactionPickerState(selected: Set(selected ?? []))
        let pickerState = ReactionPickerReducer.State()
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
        logger.trace("Copying text of \(messageId)…")
        if let message = state.messages[id: messageId] {
          #warning("FIXME")
          // environment.pasteboard.copyString(message.body)
        } else {
          logger.notice("Could not copy text: Message \(messageId) not found")
        }
        return .none

      case let .messageMenuItemTapped(.edit(messageId)):
        logger.trace("Editing \(messageId)…")
        if let message: Message = state.messages[id: messageId] {
          state.messageEditor = .init(
            messageId: messageId,
            message: message.body
          )
        } else {
          logger.notice("Could not edit message: Message \(messageId) not found")
        }
        return .none

      case let .messageMenuItemTapped(.addReaction(messageId, origin)):
        logger.trace("Reacting to \(messageId)…")
        showReactionPicker(for: messageId, origin: origin)
        return .none

      case let .messageMenuItemTapped(.remove(messageId)):
        logger.trace("Retracting \(messageId)…")
        #warning("FIXME")
        return .none
        // return environment.proseClient.retractMessage(state.chatId, messageId).fireAndForget()

      case let .message(.showMenu(payload)):
        logger.trace(
          "Received right click at \(String(describing: payload.origin)) on \(String(describing: payload.id))"
        )

        let items: [MessageMenuItem]
        if let id = payload.id {
          items = [
            .item(.action(.copyText(id), title: "Copy text")),
            .item(.action(.addReaction(id, origin: payload.origin.cgRect), title: "Add reaction…")),
            .separator,
            .item(.action(.edit(id), title: "Edit…", isDisabled: true)),
            .item(.action(.remove(id), title: "Remove message", isDisabled: true)),
          ]
        } else {
          items = [.item(.staticText("No action"))]
        }
        var menu = MessageMenuState(origin: payload.origin.anchor.cgPoint, items: items)

        let loggedInUserJID = state.currentUser

        if let messageId = payload.id,
           let message = state.messages[id: messageId],
           message.from == loggedInUserJID
        {
          menu.updateItem(withTag: .edit) {
            $0.isDisabled = false
          }
          menu.updateItem(withTag: .remove) {
            $0.isDisabled = false
          }
        }

        state.menu = menu

        return .none

      case let .message(.showReactions(payload)):
        logger.trace("Showing reactions for \(String(describing: payload.id))…")

        if let messageId = payload.id {
          showReactionPicker(for: messageId, origin: payload.origin.cgRect)
        } else {
          logger.notice("Cannot show reactions: No message selected")
        }
        return .none

      case let .message(.toggleReaction(payload)):
        logger.trace("Toggling reaction \(payload.reaction) on \(String(describing: payload.id))…")

        if let messageId = payload.id {
          #warning("FIXME")
          return .none
//          return environment.proseClient
//            .toggleReaction(state.chatId, messageId, Reaction(payload.reaction))
//            .fireAndForget()
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
        guard let messageId = state.reactionPicker?.messageId else {
          preconditionFailure("We should have stored the message ID")
        }
        #warning("FIXME")
        return .none
//        return environment.proseClient
//          .addReaction(state.chatId, messageId, reaction)
//          .fireAndForget()

      case let .reactionPicker(.deselect(reaction)):
        guard let messageId = state.reactionPicker?.messageId else {
          preconditionFailure("We should have stored the message ID")
        }
        let loggedInUserJID = state.currentUser
        #warning("FIXME")
        return .none
        // state.messages[id: messageId]?.reactions.toggleReaction(reaction, for: loggedInUserJID)
//        return environment.proseClient
//          .toggleReaction(state.chatId, messageId, reaction)
//          .fireAndForget()

      case .reactionPickerDismissed:
        hideReactionPicker()
        return .none

      case let .messageEditor(.saveEdit(messageId, newMessage)):
        state.messageEditor = nil
        #warning("FIXME")
        return .none
//        return environment.proseClient
//          .updateMessage(state.chatId, messageId, newMessage)
//          .fireAndForget()

      case .messageEditor(.cancelTapped), .messageEditorDismissed, .editMessageResult(.success):
        state.messageEditor = nil
        return .none

      case .editMessageResult(.failure):
        // Ignore the error for now. There is no error handling in the library so far.
        // FIXME: https://github.com/prose-im/prose-app-macos/issues/114
        return .none

      case .messageEditor:
        return .none
      }
    }
  }
}

extension ChatReducer.State {
  var messageEditor: EditMessageReducer.State? {
    get { self.get(\.messageEditor) }
    set { self.set(\.messageEditor, newValue) }
  }
}

struct MessageReactionPickerState: Equatable {
  let messageId: ProseBackend.Message.ID
  var pickerState: ReactionPickerReducer.State
  let origin: CGRect
}
