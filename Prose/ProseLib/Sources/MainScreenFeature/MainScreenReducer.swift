//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import ConversationFeature
import CredentialsClient
import ProseCoreTCA
import SidebarFeature
import TcaHelpers
import TCAUtils
import UnreadFeature

public struct MainScreen: ReducerProtocol {
  public typealias State = SessionState<MainScreenState>

  public struct MainScreenState: Equatable {
    public var sidebar = Sidebar.SidebarState()

    // https://github.com/prose-im/prose-app-macos/issues/45 says we should disabled this,
    // but we don't support any other predictable value, so let's keep it like this for now.
    var route = Route.unreadStack(.init())

    public init() {}
  }

  public enum Action: Equatable {
    case sidebar(Sidebar.Action)
    case unreadStack(UnreadAction)
    case chat(ConversationScreenReducer.Action)

    case reconnectButtonTapped
  }

  enum Route: Equatable {
    case unreadStack(UnreadState)
    case replies
    case directMessages
    case peopleAndGroups
    case chat(ConversationScreenReducer.ConversationState)
  }

  public init() {}

  @Dependency(\.accountsClient) var accounts
  @Dependency(\.credentialsClient) var credentials
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.pasteboardClient) var pasteboard

  public var body: some ReducerProtocol<State, Action> {
    self.core

    Scope(state: \.sidebar, action: /Action.sidebar) {
      Sidebar()
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
        var effects = EffectTask<MainScreen.Action>.none

        // If another chat was selected already, we'll manually send the `.onAppear` and
        // `.onDisappear` actions, because SwiftUI doesn't and simply sees it as a content change.
        if var priorConversationState = state.get(MainScreen.Route.Paths.chat) {
          effects = .concatenate([
            ConversationScreenReducer().reduce(into: &priorConversationState, action: .onDisappear)
              .map(MainScreen.Action.chat),
            ConversationScreenReducer().reduce(into: &conversationState, action: .onAppear)
              .map(MainScreen.Action.chat),
          ])
        }

        state.route = .chat(conversationState.childState)
        return effects
      }
      return .none
    }
    Scope(state: \.route, action: /.self) {
      EmptyReducer()
        .ifCaseLet(/Route.unreadStack, action: /Action.unreadStack) {
          Reduce(unreadReducer, environment: .init())
        }
    }
    EmptyReducer()
      .ifLet(\.chat, action: /Action.chat) {
        ConversationScreenReducer()
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

private extension SessionState where ChildState == MainScreen.MainScreenState {
  var sidebar: Sidebar.State {
    get { self.get(\.sidebar) }
    set { self.set(\.sidebar, newValue) }
  }

  var chat: ConversationScreenReducer.State? {
    get { self.get(MainScreen.Route.Paths.chat) }
    set { self.set(MainScreen.Route.Paths.chat, newValue) }
  }
}

private extension MainScreen.Route {
  enum Paths {
    static let chat: OptionalPath = (\MainScreen.MainScreenState.route)
      .case(CasePath(MainScreen.Route.chat))
  }
}
