//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AddressBookFeature
import ComposableArchitecture
import ConversationFeature
import PasteboardClient
import ProseCoreTCA
import SidebarFeature
import SwiftUI
import TcaHelpers
import Toolbox
import UnreadFeature

// MARK: - View

public struct MainScreen: View {
  public typealias State = SessionState<MainScreenState>
  public typealias Action = MainScreenAction

  private let store: Store<State, Action>
  @ObservedObject private var viewStore: ViewStore<SessionState<None>, Never>

  // swiftlint:disable:next type_contents_order
  public init(store: Store<State, Action>) {
    self.store = store
    self.viewStore = ViewStore(
      store.scope(state: { SessionState(currentUser: $0.currentUser, childState: .none) })
        .actionless
    )
  }

  public var body: some View {
    NavigationView {
      SidebarView(store: self.store.scope(state: \.scoped.sidebar, action: Action.sidebar))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("Sidebar")

      SwitchStore(self.store.scope(state: \.route)) {
        CaseLet(
          state: CasePath(MainScreenState.Route.unreadStack).extract,
          action: MainScreenAction.unreadStack,
          then: UnreadScreen.init(store:)
        )
        CaseLet(
          state: { route in
            CasePath(MainScreenState.Route.chat).extract(from: route)
              .map { SessionState(currentUser: self.viewStore.currentUser, childState: $0) }
          },
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
  SessionState<MainScreenState>,
  MainScreenAction,
  MainScreenEnvironment
>.combine([
  sidebarReducer.pullback(
    state: \.sidebar,
    action: CasePath(MainScreenAction.sidebar),
    environment: \.sidebar
  ),
  unreadReducer._pullback(
    state: (\SessionState<MainScreenState>.route).case(CasePath(MainScreenState.Route.unreadStack)),
    action: CasePath(MainScreenAction.unreadStack),
    environment: \.unread
  ),
  conversationReducer.optional().pullback(
    state: \.chat,
    action: CasePath(MainScreenAction.chat),
    environment: \.chat
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
    var conversationState = SessionState(
      currentUser: state.currentUser,
      childState: ConversationState(chatId: jid)
    )
    var effects = Effect<MainScreenAction, Never>.none

    // If another chat was selected already, we'll manually send the `.onAppear` and
    // `.onDisappear` actions, because SwiftUI doesn't and simply sees it as a content change.
    if var priorConversationState = state.get(MainScreenState.Route.Paths.chat) {
      effects = .concatenate([
        conversationReducer(&priorConversationState, .onDisappear, environment.chat)
          .map(MainScreenAction.chat),
        conversationReducer(&conversationState, .onAppear, environment.chat)
          .map(MainScreenAction.chat),
      ])
    }

    state.route = .chat(conversationState.childState)
    return effects
  }
  return .none
}

// MARK: State

public struct MainScreenState: Equatable {
  public var sidebar = SidebarState()
  public fileprivate(set) var isPlaceholder = false

  // https://github.com/prose-im/prose-app-macos/issues/45 says we should disabled this,
  // but we don't support any other predictable value, so let's keep it like this for now.
  var route = Route.unreadStack(.init())

  public init() {}
}

private extension SessionState where ChildState == MainScreenState {
  var sidebar: SessionState<SidebarState> {
    get { self.get(\.sidebar) }
    set { self.set(\.sidebar, newValue) }
  }

  var chat: SessionState<ConversationState>? {
    get { self.get(MainScreenState.Route.Paths.chat) }
    set { self.set(MainScreenState.Route.Paths.chat, newValue) }
  }
}

private extension MainScreenState.Route {
  enum Paths {
    static let chat: OptionalPath = (\MainScreenState.route)
      .case(CasePath(MainScreenState.Route.chat))
  }
}

public extension SessionState where ChildState == MainScreenState {
  static var placeholder: Self = {
    var state = SessionState(
      currentUser: .init(jid: .init(rawValue: "hello@world.org").expect("Invalid placeholder JID")),
      childState: MainScreenState()
    )
    state.isPlaceholder = true
    return state
  }()
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

// MARK: Actions

public enum MainScreenAction: Equatable {
  case sidebar(SidebarAction)
  case unreadStack(UnreadAction)
  case chat(ConversationAction)
}

// MARK: Environment

public struct MainScreenEnvironment {
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

extension MainScreenEnvironment {
  var chat: ConversationEnvironment {
    .init(
      proseClient: self.proseClient,
      pasteboard: self.pasteboard,
      mainQueue: self.mainQueue
    )
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
        initialState: .init(
          currentUser: .init(jid: "preview@prose.org"),
          childState: MainScreenState()
        ),
        reducer: mainWindowReducer,
        environment: MainScreenEnvironment(
          proseClient: .noop,
          pasteboard: .live(),
          mainQueue: .main
        )
      ))
    }
  }
#endif
