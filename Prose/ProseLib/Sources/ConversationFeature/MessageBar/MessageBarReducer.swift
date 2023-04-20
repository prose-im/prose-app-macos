//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import ComposableArchitecture
import ProseCore
import ProseUI
import TCAUtils
import Toolbox

extension Duration {
  static let saveDraftDelay: Self = .milliseconds(750)
}

public struct MessageBarReducer: ReducerProtocol {
  public typealias State = ChatSessionState<MessageBarState>

  public struct MessageBarState: Equatable {
    var messageField = MessageFieldReducer.MessageFieldState()
    var emojiPicker: ReactionPickerReducer.State?

    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onAppear
    case onDisappear

    case emojiButtonTapped
    case emojiPickerDismissed

    case messageSendResult(TaskResult<None>)
    case loadDraftResult(TaskResult<String?>)
    case binding(BindingAction<ChatSessionState<MessageBarState>>)

    case messageField(MessageFieldReducer.Action)
    case emojiPicker(ReactionPickerReducer.Action)
  }

  enum EffectToken: Hashable, CaseIterable {
    case observeParticipantStates
    case sendMessage
    case saveDraft
    case loadDraft
  }

  public init() {}

  @Dependency(\.accountsClient) var accounts

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Scope(state: \.messageField, action: /Action.messageField) {
      MessageFieldReducer()
        .onChange(of: \.isComposing) { isComposing, state, _ in
          .fireAndForget { [currentUser = state.currentUser, chatId = state.chatId] in
            try await self.accounts.client(currentUser).setUserIsComposing(chatId, isComposing)
          }
        }
        .onChange(of: \.message) { message, state, _ in
          .fireAndForget { [currentUser = state.currentUser, chatId = state.chatId] in
            try await Task.sleep(for: .saveDraftDelay)
            try await self.accounts.client(currentUser).saveDraft(chatId, message)
          }.cancellable(id: EffectToken.saveDraft, cancelInFlight: true)
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
        return .merge(
          .task { [currentUser = state.currentUser, chatId = state.chatId] in
            await .loadDraftResult(TaskResult {
              try await self.accounts.client(currentUser).loadDraft(chatId)
            })
          }.cancellable(id: EffectToken.loadDraft),
          MessageFieldReducer().reduce(into: &state.messageField, action: .onAppear)
            .map(Action.messageField)
        )

      case .onDisappear:
        return .merge(
          MessageFieldReducer().reduce(into: &state.messageField, action: .onDisappear)
            .map(Action.messageField),
          .cancel(token: EffectToken.self)
        )

      case let .emojiPicker(.select(emoji)):
        state.emojiPicker = nil
        state.messageField.message.append(contentsOf: emoji.rawValue)
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

      case let .loadDraftResult(.success(message)):
        state.messageField.message = message ?? ""
        return .none

      case let .loadDraftResult(.failure(error)):
        logger.error("Failed to load draft. \(error)")
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
  var composingUserInfos: [UserInfo] {
    self.composingUsers.compactMap { user in
      self.userInfos[user]
    }
  }

  var messageField: MessageFieldReducer.State {
    get { self.get(\.messageField) }
    set { self.set(\.messageField, newValue) }
  }
}
