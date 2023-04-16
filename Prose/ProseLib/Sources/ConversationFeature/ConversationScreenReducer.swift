//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import ConversationInfoFeature
import ProseBackend
import ProseCoreTCA

public struct ConversationScreenReducer: ReducerProtocol {
  public typealias State = SessionState<ConversationState>

  public struct ConversationState: Equatable {
    let chatId: BareJid
    var userInfos = [BareJid: UserInfo]()
    var info: ConversationInfoReducer.State?
    var toolbar = ToolbarReducer.ToolbarState()
    var messageBar = MessageBarReducer.MessageBarState()
    var chat = ChatReducer.ChatState()

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
    case userInfosResult(TaskResult<[BareJid: UserInfo]>)
    case event(ClientEvent)

    case info(ConversationInfoReducer.Action)
    case toolbar(ToolbarReducer.Action)
    case messageBar(MessageBarReducer.Action)
    case chat(ChatReducer.Action)
  }

  enum EffectToken: Hashable, CaseIterable {
    case loadMessages
    case loadContacts
    case observeEvents
  }

  public init() {}

  @Dependency(\.accountsClient) var accounts

  public var body: some ReducerProtocol<State, Action> {
    Scope(state: \.messageBar, action: /Action.messageBar) {
      MessageBarReducer()
    }
    EmptyReducer()
      .ifLet(\.info, action: /Action.info) {
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
      case .onAppear:
        let currentUser = state.currentUser
        let chatId = state.childState.chatId

        return .merge(
          .task {
            await .messagesResult(TaskResult {
              let messages = try await self.accounts.client(currentUser)
                .loadLatestMessages(chatId, nil, true)
              return IdentifiedArray(uniqueElements: messages)
            })
          }.cancellable(id: EffectToken.loadMessages),
          .task { [currentAccount = state.selectedAccount] in
            await .userInfosResult(TaskResult {
              var contacts = try await self.accounts.client(currentUser).loadContacts().map {
                UserInfo(jid: $0.jid, name: $0.name, avatar: $0.avatar)
              }
              contacts.append(.init(
                jid: currentUser, name: currentAccount.username, avatar: currentAccount.avatar
              ))
              return Dictionary(
                zip(contacts.map(\.jid), contacts),
                uniquingKeysWith: { _, last in last }
              )
            })
          }.cancellable(id: EffectToken.loadContacts),
          .run { send in
            let events = try self.accounts.client(currentUser).events()
            for try await event in events {
              switch event {
              case let .contactChanged(jid) where jid == chatId:
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
          }.cancellable(id: EffectToken.observeEvents)
        )

      case .onDisappear:
        return .cancel(token: EffectToken.self)

      case let .messagesResult(.success(messages)):
        state.chat.messages = messages
        #warning("FIXME")
        return .none
//        return environment.proseClient.markMessagesReadInChat(state.childState.chatId)
//          .fireAndForget()

      case let .messagesResult(.failure(error)):
        logger.error(
          "Could not load messages. \(error.localizedDescription, privacy: .public)"
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

      case let .userInfosResult(.success(userInfos)):
        state.userInfos = userInfos
        return .none

      case let .userInfosResult(.failure(error)):
        logger.error(
          "Could not load user infos. \(error.localizedDescription, privacy: .public)"
        )
        return .none

      case .toolbar(.binding(\.$isShowingInfo)):
        if state.toolbar.isShowingInfo, state.info == nil {
          state.info = .init()
        }
        return .none

      case let .event(.contactChanged(jid)):
        #warning("FIXME")
        return .none

      case .event(.messagesAppended):
        let lastMessageId = state.chat.messages.last?.id

        return .task { [currentUser = state.currentUser, chatId = state.childState.chatId] in
          await .latestMessagesResult(TaskResult {
            try await self.accounts.client(currentUser)
              .loadLatestMessages(chatId, lastMessageId, false)
          })
        }

      case let .event(.messagesUpdated(_, messageIds)):
        return .task { [currentUser = state.currentUser, chatId = state.childState.chatId] in
          await .updateMessageResult(TaskResult {
            try await self.accounts.client(currentUser).loadMessagesWithIds(chatId, messageIds)
          })
        }

      case let .event(.messagesDeleted(_, messageIds)):
        let messageIds = Set(messageIds)
        state.chat.messages.removeAll(where: { messageIds.contains($0.id) })
        return .none

      case .info, .toolbar, .messageBar, .chat, .event:
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

  func get<T>(_ toLocalState: (ChildState) -> T) -> ChatSessionState<T> {
    ChatSessionState<T>(
      currentUser: self.currentUser,
      chatId: self.childState.chatId,
      userInfos: self.childState.userInfos,
      childState: toLocalState(self.childState)
    )
  }

  mutating func set<T>(_ keyPath: WritableKeyPath<ChildState, T>, _ newValue: ChatSessionState<T>) {
    self.childState[keyPath: keyPath] = newValue.childState
  }
}
