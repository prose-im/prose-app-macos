//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import ProseBackend
import ProseCoreTCA
import ProseUI
import Toolbox

public struct MessageBarReducer: ReducerProtocol {
  public typealias State = ChatSessionState<MessageBarState>

  public struct MessageBarState: Equatable {
    var typingUsers = [UserInfo]()
    var messageField = MessageFieldReducer.State()
    var emojiPicker: ReactionPickerReducer.State?

    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onAppear
    case onDisappear

    case emojiButtonTapped
    case emojiPickerDismissed

    case typingUsersChanged([BareJid])
    case messageSendResult(TaskResult<None>)
    case binding(BindingAction<ChatSessionState<MessageBarState>>)

    case messageField(MessageFieldReducer.Action)
    case emojiPicker(ReactionPickerReducer.Action)
  }

  enum EffectToken: Hashable, CaseIterable {
    case observeParticipantStates
    case sendMessage
  }

  public init() {}

  @Dependency(\.accountsClient) var accounts

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Scope(state: \.messageField, action: /Action.messageField) {
      MessageFieldReducer()
    }
    self.core
      .ifLet(\.emojiPicker, action: /Action.emojiPicker) {
        ReactionPickerReducer()
      }

    #warning("TODO: Send chat state")
//    .onChange(of: { TextFieldState($0.childState) }) { current, state, _, environment in
//      if !current.isFocused || current.message.isEmpty {
//        // If the text field is not focused or empty we don't consider the user typing.
//        return .merge(
//          environment.proseClient
//            .sendChatState(state.chatId, .active)
//            .fireAndForget(),
//          .cancel(id: MessageComposingFieldEffectToken.pauseTyping)
//        )
//      } else {
//        return .merge(
//          environment.proseClient
//            .sendChatState(state.chatId, .composing)
//            .fireAndForget(),
//          EffectTask(value: .setChatState(.paused))
//            .delay(for: .pauseTypingDebounceDuration, scheduler: environment.mainQueue)
//            .eraseToEffect()
//            .cancellable(id: MessageComposingFieldEffectToken.pauseTyping, cancelInFlight: true)
//        )
//      }
//    },
//    AnyReducer { state, action, environment in
//      switch action {
//      case let .setChatState(chatState):
//        return environment.proseClient
//          .sendChatState(state.chatId, chatState)
//          .fireAndForget()
//
//      case .onDisappear:
//        return .cancel(token: MessageComposingFieldEffectToken.self)
//
//      case .field:
//        return .none
//      }
//    }
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none
//        let chatId = state.chatId
//        let loggedInUserJID = state.currentUser
//        return environment.proseClient.activeChats()
//          .compactMap { $0[chatId] }
//          .map(\.participantStates)
//          .map { (participantStates: [BareJid: ProseCoreTCA.ChatState]) in
//            participantStates
//              .filter { $0.value.kind == .composing }
//              .filter { $0.key != loggedInUserJID }
//              .map(\.key)
//          }
//          .replaceError(with: [])
//          .removeDuplicates()
//          .eraseToEffect(Action.typingUsersChanged)
//          .cancellable(id: EffectToken.observeParticipantStates)

      case .onDisappear:
        return .cancel(token: EffectToken.self)

      case let .typingUsersChanged(jids):
        state.typingUsers = jids.map { state.userInfos[$0, default: .init(jid: $0)] }
        return .none

      case let .emojiPicker(.select(reaction)):
        state.emojiPicker = nil
        state.messageField.message.append(contentsOf: reaction.rawValue)
        return .none

      case .emojiPickerDismissed:
        state.emojiPicker = nil
        return .none

      case let .messageField(.send(messageContent)):
        return .task { [currentUser = state.currentUser, to = state.chatId] in
          await .messageSendResult(TaskResult {
            try await self.accounts.client(currentUser)
              .expect("Missing client")
              .sendMessage(to, messageContent)
            return .none
          })
        }.cancellable(id: EffectToken.sendMessage)

      case .messageSendResult(.success):
        state.messageField.message = ""
        return .none

      case let .messageSendResult(.failure(error)):
        logger.notice("Error when sending message: \(error)")
        // Ignore the error for now. There is no error handling in the library so far.
        // FIXME: https://github.com/prose-im/prose-app-macos/issues/114
        return .none

      case .emojiButtonTapped:
        state.emojiPicker = .init()
        return .none

      case .messageField, .binding, .emojiPicker:
        return .none
      }
    }
  }
}

// private extension MessageBarReducer.State {
//  var messageField: ChatSessionState<MessageBarReducer.MessageBarState> {
//    get {
//      var messageField = self.get(\.messageField)
//      messageField.placeholder = l10n
//        .fieldPlaceholder(self.userInfos[self.chatId]?.name ?? self.chatId.rawValue)
//      return messageField
//    }
//    set { self.set(\.messageField, newValue) }
//  }
// }
