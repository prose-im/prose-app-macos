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
    case userInfosResult(TaskResult<[BareJid: UserInfo]>)
    case event(ClientEvent)

    case info(ConversationInfoReducer.Action)
    case toolbar(ToolbarReducer.Action)
    case messageBar(MessageBarReducer.Action)
    case chat(ChatReducer.Action)
  }

  enum EffectToken: Hashable, CaseIterable {
    case loadMessages
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
              let messages = try await self.accounts.client(currentUser)?
                .loadLatestMessages(chatId, nil, true) ?? []
              return IdentifiedArray(uniqueElements: messages)
            })
          }.cancellable(id: EffectToken.loadMessages),
          .run { send in
            let events = self.accounts.client(currentUser)
              .expect("Missing client for \(currentUser)").events()
            for try await event in events {
              switch event {
              case let .contactChanged(jid) where jid == chatId:
                await send(.event(event))
              case let .messagesAppended(conversation) where conversation == chatId:
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

      case let .event(.messagesAppended(conversation)):
        #warning("FIXME")
        let lastMessageStanzaId = state.chat.messages.last(where: { $0.stanzaId != nil })?.stanzaId

        return .task { [currentUser = state.currentUser, chatId = state.childState.chatId] in
          await .latestMessagesResult(TaskResult {
            try await self.accounts.client(currentUser)
              .expect("Missing client")
              .loadLatestMessages(chatId, lastMessageStanzaId, false)
          })
        }

      case let .event(.messagesUpdated(conversation, messageIds)):
        #warning("FIXME")
        return .none

      case let .event(.messagesDeleted(conversation, messageIds)):
        #warning("FIXME")
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
