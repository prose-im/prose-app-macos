//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import ProseCore
import ProseUI
import TCAUtils
import Toolbox

public struct MessageBarReducer: ReducerProtocol {
  public typealias State = ChatSessionState<MessageBarState>

  public struct MessageBarState: Equatable {
    var typingUsers = [UserInfo]()
    var messageField = MessageFieldReducer.MessageFieldState()
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
    case debounceChatState
  }

  public init() {}

  @Dependency(\.accountsClient) var accounts

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Scope(state: \.messageField, action: /Action.messageField) {
      MessageFieldReducer()
        .onChange(of: \.childState) { _, state, _ in
          // If the text field is not focused or empty we don't consider the user typing.
          if !state.isFocused || state.message.isEmpty {
            return .fireAndForget { [currentUser = state.currentUser, chatId = state.chatId] in
              try await self.accounts.client(currentUser).sendChatState(chatId, .active)
            }.cancellable(id: EffectToken.debounceChatState, cancelInFlight: true)
          } else {
            return .fireAndForget { [currentUser = state.currentUser, chatId = state.chatId] in
              try await Task.sleep(for: .composeDebounceDuration)
              try await self.accounts.client(currentUser).sendChatState(chatId, .composing)
              try await Task.sleep(for: .pauseTypingDebounceDuration - .composeDebounceDuration)
              try await self.accounts.client(currentUser).sendChatState(chatId, .paused)
            }.cancellable(id: EffectToken.debounceChatState, cancelInFlight: true)
          }
        }
    }
    self.core
      .ifLet(\.emojiPicker, action: /Action.emojiPicker) {
        ReactionPickerReducer()
      }
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none
        #warning("FIXME")
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
        #warning("FIXME")
        // state.typingUsers = jids.map { state.userInfos[$0, default: .init(jid: $0)] }
        return .none

      case let .emojiPicker(.select(emoji)):
        state.emojiPicker = nil
        state.messageField.message.append(contentsOf: emoji)
        return .none

      case .emojiPickerDismissed:
        state.emojiPicker = nil
        return .none

      case .messageField(.sendButtonTapped):
        let message = state.messageField.trimmedMessage
        guard !message.isEmpty else {
          return .none
        }

        return .task { [currentUser = state.currentUser, to = state.chatId] in
          await .messageSendResult(TaskResult {
            try await self.accounts.client(currentUser).sendMessage(to, message)
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

extension MessageBarReducer.State {
  var messageField: MessageFieldReducer.State {
    get { self.get(\.messageField) }
    set { self.set(\.messageField, newValue) }
  }
}

extension Duration {
  static let composeDebounceDuration: Self = .milliseconds(500)
  static let pauseTypingDebounceDuration: Self = .seconds(30)
}
