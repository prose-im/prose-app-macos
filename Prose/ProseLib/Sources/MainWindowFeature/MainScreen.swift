//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AddressBookFeature
import ComposableArchitecture
import ConversationFeature
import ProseCoreTCA
import SidebarFeature
import SwiftUI
import TcaHelpers
import Toolbox
import UnreadFeature

// MARK: - View

public struct MainScreen: View {
  public typealias State = MainScreenState
  public typealias Action = MainScreenAction

  private let store: Store<State, Action>

  // swiftlint:disable:next type_contents_order
  public init(store: Store<State, Action>) {
    self.store = store
  }

  public var body: some View {
    NavigationView {
      SidebarView(store: self.store.scope(state: \.sidebar, action: Action.sidebar))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("Sidebar")

      SwitchStore(self.store.scope(state: \.route)) {
        CaseLet(
          state: CasePath(MainScreenState.Route.unreadStack).extract,
          action: MainScreenAction.unreadStack,
          then: UnreadScreen.init(store:)
        )
        CaseLet(
          state: CasePath(MainScreenState.Route.chat).extract,
          action: MainScreenAction.chat,
          then: ConversationScreen.init(store:)
        )
        Default {
          Text("Not implemented.")
        }
      }
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier("MainContent")
    }
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let mainWindowReducer = Reducer<
  MainScreenState,
  MainScreenAction,
  MainScreenEnvironment
>.combine([
  sidebarReducer.pullback(
    state: \.sidebar,
    action: CasePath(MainScreenAction.sidebar),
    environment: \.sidebar
  ),
  unreadReducer._pullback(
    state: (\MainScreenState.route).case(CasePath(MainScreenState.Route.unreadStack)),
    action: CasePath(MainScreenAction.unreadStack),
    environment: \.unread
  ),
  conversationReducer._pullback(
    state: (\MainScreenState.route).case(CasePath(MainScreenState.Route.chat)),
    action: CasePath(MainScreenAction.chat),
    environment: \.chat,
    breakpointOnNil: false
  ),
])
.onChange(of: \.sidebar.selection) { selection, state, _, environment in
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
    var priorRoute = state.route
    var conversationState = ConversationState(chatId: jid)
    var effects = Effect<MainScreenAction, Never>.none

    // If another chat was selected already, we'll manually send the `.onAppear` and
    // `.onDisappear` actions, because SwiftUI doesn't and simply sees it as a content change.
    if case var .chat(priorConversationState) = priorRoute {
      effects = .concatenate([
        conversationReducer(&priorConversationState, .onDisappear, environment.chat)
          .map(MainScreenAction.chat),
        conversationReducer(&conversationState, .onAppear, environment.chat)
          .map(MainScreenAction.chat),
      ])
    }

    state.route = .chat(conversationState)
    return effects
  }
  return .none
}

// MARK: State

public struct MainScreenState: Equatable {
  public var sidebar: SidebarState
  public private(set) var isPlaceholder = false

  var route = Route.unreadStack(.init())

  public init(jid: JID) {
    self.sidebar = .init(credentials: jid)
  }
}

extension MainScreenState {
  enum Route: Equatable {
    case unreadStack(UnreadState)
    case replies
    case directMessages
    case peopleAndGroups
    case chat(ConversationState)
  }
}

public extension MainScreenState {
  static var placeholder: MainScreenState = {
    var state = MainScreenState(
      jid: .init(rawValue: "hello@world.org").expect("Invalid placeholder JID")
    )
    state.isPlaceholder = true
    return state
  }()
}

// MARK: Actions

public enum MainScreenAction: Equatable {
  case sidebar(SidebarAction)
  case unreadStack(UnreadAction)
  case chat(ConversationAction)
}

// MARK: Environment

public struct MainScreenEnvironment {
  var proseClient: ProseClient
  var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(
    proseClient: ProseClient,
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.proseClient = proseClient
    self.mainQueue = mainQueue
  }
}

extension MainScreenEnvironment {
  var chat: ConversationEnvironment {
    .init(proseClient: self.proseClient, mainQueue: self.mainQueue)
  }

  var sidebar: SidebarEnvironment {
    .init(proseClient: self.proseClient, mainQueue: self.mainQueue)
  }

  var unread: UnreadEnvironment {
    .init()
  }
}

// MARK: - Previews

#if DEBUG
  import PreviewAssets

  internal struct MainWindow_Previews: PreviewProvider {
    static var previews: some View {
      MainScreen(store: Store(
        initialState: MainScreenState(jid: "preview@prose.org"),
        reducer: mainWindowReducer,
        environment: MainScreenEnvironment(
          proseClient: .noop,
          mainQueue: .main
        )
      ))
    }
  }
#endif
