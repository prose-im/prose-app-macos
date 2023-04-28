//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import ComposableArchitecture
import ProseCore

public struct ConversationScreenReducer: ReducerProtocol {
  public typealias State = SessionState<ConversationState>

  public struct ConversationState: Equatable {
    let chatId: BareJid
    var composingUsers = [BareJid]()
    var info = ConversationInfoReducer.ConversationInfoState()
    var toolbar = ToolbarReducer.ToolbarState()
    var messageBar = MessageBarReducer.MessageBarState()
    var chat = ChatReducer.ChatState()
    var isVisible = false

    public init(chatId: BareJid) {
      self.chatId = chatId
    }
  }

  public enum Action: Equatable {
    case onAppear
    case onDisappear

    case messagesResult(TaskResult<IdentifiedArrayOf<Message>>)
    case latestMessagesResult(TaskResult<[Message]>)
    case updateMessageResult(TaskResult<[Message]>)
    case composingUsersResult(TaskResult<[BareJid]>)
    case event(ClientEvent)

    case info(ConversationInfoReducer.Action)
    case toolbar(ToolbarReducer.Action)
    case messageBar(MessageBarReducer.Action)
    case chat(ChatReducer.Action)
  }

  enum EffectToken: Hashable, CaseIterable {
    case loadMessages
    case loadComposingUsers
    case observeEvents
  }

  public init() {}

  @Dependency(\.accountsClient) var accounts

  public var body: some ReducerProtocol<State, Action> {
    Scope(state: \.messageBar, action: /Action.messageBar) {
      MessageBarReducer()
    }
    Scope(state: \.info, action: /Action.info) {
      ConversationInfoReducer()
    }
    Scope(state: \.toolbar, action: /Action.toolbar) {
      ToolbarReducer()
    }
    Scope(state: \.chat, action: /Action.chat) {
      ChatReducer()
    }
    self.core
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear where !state.isVisible:
        state.isVisible = true
        let selectedAccountId = state.selectedAccountId
        let chatId = state.childState.chatId

        return .merge(
          .task {
            await .messagesResult(TaskResult {
              let messages = try await self.accounts.client(selectedAccountId)
                .loadLatestMessages(chatId, nil, true)
              return IdentifiedArray(uniqueElements: messages)
            })
          }.cancellable(id: EffectToken.loadMessages),
          .task {
            await .composingUsersResult(TaskResult {
              try await self.accounts.client(selectedAccountId)
                .loadComposingUsersInConversation(chatId)
            })
          }.cancellable(id: EffectToken.loadComposingUsers),
          .run { send in
            let events = try self.accounts.client(selectedAccountId).events()
            for try await event in events {
              switch event {
              case let .composingUsersChanged(jid) where jid == chatId:
                await send(.event(event))
              case let .messagesAppended(conversation, _) where conversation == chatId:
                await send(.event(event))
              case let .messagesUpdated(conversation, _) where conversation == chatId:
                await send(.event(event))
              case let .messagesDeleted(conversation, _) where conversation == chatId:
                await send(.event(event))
              default:
                break
              }
            }
          }.cancellable(id: EffectToken.observeEvents),
          MessageBarReducer().reduce(into: &state.messageBar, action: .onAppear)
            .map(Action.messageBar),
          ConversationInfoReducer().reduce(into: &state.info, action: .onAppear)
            .map(Action.info)
        )

      case .onDisappear:
        let effects: [EffectTask<Action>] = [
          MessageBarReducer().reduce(into: &state.messageBar, action: .onDisappear)
            .map(Action.messageBar),
          ConversationInfoReducer().reduce(into: &state.info, action: .onDisappear)
            .map(Action.info),
          .cancel(token: EffectToken.self),
        ]

        state.isVisible = false
        state.info = .init()
        state.toolbar.isShowingInfo = false

        return .merge(effects)

      case let .messagesResult(.success(messages)):
        state.chat.messages = messages
        return .none

      case let .messagesResult(.failure(error)):
        logger.error(
          "Could not load messages. \(error.localizedDescription)"
        )
        return .none

      case let .latestMessagesResult(.success(messages)):
        state.chat.messages.append(contentsOf: messages)
        return .none

      case let .latestMessagesResult(.failure(error)):
        logger.error("Failed to load latest messages. \(error.localizedDescription)")
        return .none

      case let .updateMessageResult(.success(messages)):
        for message in messages {
          state.chat.messages[id: message.id] = message
        }
        return .none

      case let .updateMessageResult(.failure(error)):
        logger.error("Failed to load updated messages. \(error.localizedDescription)")
        return .none

      case let .composingUsersResult(.success(composingUsers)):
        state.composingUsers = composingUsers
        return .none

      case let .composingUsersResult(.failure(error)):
        logger.error(
          "Could not load composing users. \(error.localizedDescription)"
        )
        return .none

      case .toolbar(.toggleInfoButtonTapped):
        if state.toolbar.isShowingInfo, state.info == nil {
          state.info = .init()
        }
        return .none

      case .event(.composingUsersChanged):
        return .task { [accountId = state.selectedAccountId, chatId = state.childState.chatId] in
          await .composingUsersResult(TaskResult {
            try await self.accounts.client(accountId).loadComposingUsersInConversation(chatId)
          })
        }.cancellable(id: EffectToken.loadComposingUsers, cancelInFlight: true)

      case .event(.messagesAppended):
        let lastMessageId = state.chat.messages.last?.id

        return .task { [accountId = state.selectedAccountId, chatId = state.childState.chatId] in
          await .latestMessagesResult(TaskResult {
            try await self.accounts.client(accountId)
              .loadLatestMessages(chatId, lastMessageId, false)
          })
        }

      case let .event(.messagesUpdated(_, messageIds)):
        return .task { [accountId = state.selectedAccountId, chatId = state.childState.chatId] in
          await .updateMessageResult(TaskResult {
            try await self.accounts.client(accountId).loadMessagesWithIds(chatId, messageIds)
          })
        }

      case let .event(.messagesDeleted(_, messageIds)):
        let messageIds = Set(messageIds)
        state.chat.messages.removeAll(where: { messageIds.contains($0.id) })
        return .none

      case .info, .toolbar, .messageBar, .chat, .event, .onAppear:
        return .none
      }
    }
  }
}

extension ConversationScreenReducer.State {
  var chat: ChatReducer.State {
    get { self.get(\.chat) }
    set { self.set(\.chat, newValue) }
  }

  var messageBar: MessageBarReducer.State {
    get { self.get(\.messageBar) }
    set { self.set(\.messageBar, newValue) }
  }

  var toolbar: ToolbarReducer.State {
    get { self.get(\.toolbar) }
    set { self.set(\.toolbar, newValue) }
  }

  var info: ConversationInfoReducer.State {
    get { self.get(\.info) }
    set { self.set(\.info, newValue) }
  }

  func get<T>(_ toLocalState: (ChildState) -> T) -> ChatSessionState<T> {
    var userInfos = self.selectedAccount.contacts
    userInfos[self.selectedAccountId] = Contact(
      jid: self.selectedAccountId,
      name: self.selectedAccount.username,
      avatar: self.selectedAccount.avatar,
      availability: self.selectedAccount.availability,
      status: nil,
      groups: []
    )
    return ChatSessionState<T>(
      selectedAccountId: self.selectedAccountId,
      chatId: self.childState.chatId,
      userInfos: userInfos,
      composingUsers: self.childState.composingUsers,
      childState: toLocalState(self.childState)
    )
  }

  mutating func set<T>(_ keyPath: WritableKeyPath<ChildState, T>, _ newValue: ChatSessionState<T>) {
    self.childState[keyPath: keyPath] = newValue.childState
  }
}
