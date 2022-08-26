//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import ConversationInfoFeature
import IdentifiedCollections
import PasteboardClient
import ProseCoreTCA
import SwiftUI
import TcaHelpers
import Toolbox

// MARK: - View

public struct ConversationScreen: View {
  public typealias State = SessionState<ConversationState>
  public typealias Action = ConversationAction

  private let store: Store<State, Action>
  private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

  public init(store: Store<State, Action>) {
    self.store = store
  }

  public var body: some View {
    Chat(store: self.store.scope(state: \.chat, action: Action.chat))
      .safeAreaInset(edge: .bottom, spacing: 0) {
        MessageBar(store: self.store.scope(state: \.messageBar, action: Action.messageBar))
          // Make footer have a higher priority, to be accessible over the scroll view
          .accessibilitySortPriority(1)
      }
      .accessibilityIdentifier("ChatWebView")
      .accessibilityElement(children: .contain)
      .onAppear { actions.send(.onAppear) }
      .onDisappear { actions.send(.onDisappear) }
      .safeAreaInset(edge: .trailing, spacing: 0) {
        WithViewStore(
          self.store
            .scope(state: \.toolbar.childState.isShowingInfo)
        ) { showingInfo in
          HStack(spacing: 0) {
            Divider()
            IfLetStore(self.store.scope(state: \.info, action: Action.info)) { store in
              ConversationInfoView(store: store)
            } else: {
              ConversationInfoView.placeholder
            }
            .frame(width: 256)
          }
          .frame(width: showingInfo.state ? 256 : 0, alignment: .leading)
          .clipped()
        }
      }
      .toolbar {
        Toolbar(store: self.store.scope(state: \.toolbar, action: Action.toolbar))
      }
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

enum ConversationEffectToken: Hashable, CaseIterable {
  case fetchPastMessages
  case observeMessages
  case observeUserInfos
}

public let conversationReducer = Reducer<
  SessionState<ConversationState>,
  ConversationAction,
  ConversationEnvironment
>.combine([
  messageBarReducer.pullback(
    state: \.messageBar,
    action: CasePath(ConversationAction.messageBar),
    environment: { $0 }
  ),
  conversationInfoReducer.optional().pullback(
    state: \.info,
    action: CasePath(ConversationAction.info),
    environment: { _ in () }
  ),
  toolbarReducer.pullback(
    state: \.toolbar,
    action: CasePath(ConversationAction.toolbar),
    environment: { _ in () }
  ),
  chatReducer.pullback(
    state: \.chat,
    action: CasePath(ConversationAction.chat),
    environment: { $0 }
  ),
  Reducer { state, action, environment in
    switch action {
    case .onAppear:
      return .merge(
        environment.proseClient.messagesInChat(state.childState.chatId)
          .receive(on: environment.mainQueue)
          .catchToEffect()
          .map(ConversationAction.messagesResult)
          .cancellable(id: ConversationEffectToken.observeMessages, cancelInFlight: true),
        environment.proseClient.fetchPastMessagesInChat(state.childState.chatId)
          .ignoreOutput()
          .fireAndForget()
          .cancellable(id: ConversationEffectToken.fetchPastMessages, cancelInFlight: true),
        environment.proseClient.userInfos([state.chat.currentUser.jid, state.childState.chatId])
          .receive(on: environment.mainQueue)
          .catchToEffect()
          .map(ConversationAction.userInfosResult)
          .cancellable(id: ConversationEffectToken.observeUserInfos)
      )

    case .onDisappear:
      return .cancel(token: ConversationEffectToken.self)

    case let .messagesResult(.success(messages)):
      state.chat.messages = messages
      return environment.proseClient.markMessagesReadInChat(state.childState.chatId).fireAndForget()

    case let .messagesResult(.failure(error)):
      logger.error(
        "Could not load messages. \(error.localizedDescription, privacy: .public)"
      )
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
        state.info = .demo
      }
      return .none

    case .info, .toolbar, .messageBar, .chat:
      return .none
    }
  },
])

// MARK: State

public struct ConversationState: Equatable {
  let chatId: JID
  var userInfos = [JID: UserInfo]()
  var info: ConversationInfoState?
  var toolbar: ToolbarState
  var messageBar = MessageBarState()
  var chat = ChatState()

  public init(chatId: JID) {
    self.chatId = chatId
    self.toolbar = .init(user: nil)
  }
}

private extension SessionState where ChildState == ConversationState {
  var chat: ChatSessionState<ChatState> {
    get { self.get(\.chat) }
    set { self.set(\.chat, newValue) }
  }

  var messageBar: ChatSessionState<MessageBarState> {
    get { self.get(\.messageBar) }
    set { self.set(\.messageBar, newValue) }
  }

  var toolbar: ChatSessionState<ToolbarState> {
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

// MARK: Actions

public enum ConversationAction: Equatable {
  case onAppear
  case onDisappear

  case messagesResult(Result<IdentifiedArrayOf<Message>, EquatableError>)
  case userInfosResult(Result<[JID: UserInfo], EquatableError>)

  case info(ConversationInfoAction)
  case toolbar(ToolbarAction)
  case messageBar(MessageBarAction)
  case chat(ChatAction)
}

// MARK: Environment

public struct ConversationEnvironment {
  var proseClient: ProseClient
  var pasteboard: PasteboardClient
  var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(
    proseClient: ProseClient,
    pasteboard: PasteboardClient,
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.proseClient = proseClient
    self.pasteboard = pasteboard
    self.mainQueue = mainQueue
  }
}

#if DEBUG

  // MARK: - Previews

  struct ConversationScreen_Previews: PreviewProvider {
    private struct Preview: View {
      var body: some View {
        ConversationScreen(store: Store(
          initialState: .mock(ConversationState(chatId: "alexandre@crisp.chat")),
          reducer: conversationReducer,
          environment: .init(proseClient: .noop, pasteboard: .live(), mainQueue: .main)
        ))
        .previewLayout(.sizeThatFits)
      }
    }

    static var previews: some View {
      Preview()
      Preview()
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark mode")
      Preview()
        .redacted(reason: .placeholder)
        .previewDisplayName("Placeholder")
    }
  }
#endif
