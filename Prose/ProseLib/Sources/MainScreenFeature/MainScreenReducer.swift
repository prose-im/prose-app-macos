//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import ComposableArchitecture
import ConversationFeature
import CredentialsClient
import ProseCore
import SidebarFeature
import TCAUtils
import UnreadFeature

public struct MainScreenReducer: ReducerProtocol {
  public typealias State = SessionState<MainScreenState>

  public struct MainScreenState: Equatable {
    public var sidebar = SidebarReducer.SidebarState()

    // https://github.com/prose-im/prose-app-macos/issues/45 says we should disabled this,
    // but we don't support any other predictable value, so let's keep it like this for now.
    var route = Route.unreadStack(.init())

    public init() {}
  }

  public enum Action: Equatable {
    case sidebar(SidebarReducer.Action)
    case unreadStack(UnreadScreenReducer.Action)
    case chat(ConversationScreenReducer.Action)

    case reconnectButtonTapped
  }

  enum Route: Equatable {
    case unreadStack(UnreadScreenReducer.UnreadScreenState)
    case replies
    case directMessages
    case peopleAndGroups
    case chat(ConversationScreenReducer.ConversationState)
  }

  public init() {}

  @Dependency(\.accountsClient) var accounts
  @Dependency(\.credentialsClient) var credentials
  @Dependency(\.pasteboardClient) var pasteboard

  public var body: some ReducerProtocol<State, Action> {
    self.core

    Scope(state: \.sidebar, action: /Action.sidebar) {
      SidebarReducer()
    }.onChange(of: \.sidebar.selection) { selection, state, _ in
      switch selection {
      case .unreadStack, .none:
        state.route = .unreadStack(.init())
      case .replies:
        state.route = .replies
      case .directMessages:
        state.route = .directMessages
      case .peopleAndGroups:
        state.route = .peopleAndGroups
      case let .chat(jid):
        var conversationState = state
          .get { _ in ConversationScreenReducer.ConversationState(chatId: jid) }
        var effects = EffectTask<MainScreenReducer.Action>.none

        // If another chat was selected already, we'll manually send the `.onAppear` and
        // `.onDisappear` actions, because SwiftUI doesn't and simply sees it as a content change.
        if var priorConversationState = state.sessionRoute.chat {
          effects = .concatenate([
            ConversationScreenReducer().reduce(into: &priorConversationState, action: .onDisappear)
              .map(MainScreenReducer.Action.chat),
            ConversationScreenReducer().reduce(into: &conversationState, action: .onAppear)
              .map(MainScreenReducer.Action.chat),
          ])
        }

        state.route = .chat(conversationState.childState)
        return effects
      }
      return .none
    }
    Scope(state: \.sessionRoute, action: /.self) {
      EmptyReducer()
        .ifLet(\.unreadStack, action: /Action.unreadStack) {
          UnreadScreenReducer()
        }
        .ifLet(\.chat, action: /Action.chat) {
          ConversationScreenReducer()
        }
    }
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .reconnectButtonTapped:
        return .fireAndForget { [account = state.selectedAccount] in
          if let credentials = try self.credentials.loadCredentials(account.jid) {
            self.accounts.reconnectAccount(credentials, false)
          }
        }

      case .sidebar, .unreadStack, .chat:
        return .none
      }
    }
  }
}

extension MainScreenReducer.State {
  var sidebar: SidebarReducer.State {
    get { self.get(\.sidebar) }
    set { self.set(\.sidebar, newValue) }
  }

  var sessionRoute: SessionState<MainScreenReducer.Route> {
    get { self.get(\.route) }
    set { self.set(\.route, newValue) }
  }
}

extension SessionState<MainScreenReducer.Route> {
  var unreadStack: UnreadScreenReducer.State? {
    get { self.get(/MainScreenReducer.Route.unreadStack) }
    set { self.set(/MainScreenReducer.Route.unreadStack, newValue) }
  }

  var chat: ConversationScreenReducer.State? {
    get { self.get(/MainScreenReducer.Route.chat) }
    set { self.set(/MainScreenReducer.Route.chat, newValue) }
  }
}
