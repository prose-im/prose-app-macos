//
//  MainScreen.swift
//  Prose
//
//  Created by Rémi Bardon on 01/06/2022.
//

import AddressBookFeature
import ComposableArchitecture
import ConversationFeature
import ProseCoreStub
import SharedModels
import SidebarFeature
import SwiftUI
import TcaHelpers
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
        environment: { _ in }
    ),
    unreadReducer._pullback(
        state: (\MainScreenState.route).case(CasePath(MainScreenState.Route.unreadStack)),
        action: CasePath(MainScreenAction.unreadStack),
        environment: { _ in .stub }
    ),
    conversationReducer._pullback(
        state: (\MainScreenState.route).case(CasePath(MainScreenState.Route.chat)),
        action: CasePath(MainScreenAction.chat),
        environment: { $0.chat }
    ),
])
.onChange(of: \.sidebar.selection) { selection, state, _, _ in
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
        state.route = .chat(.init(chatId: .person(id: jid), recipient: "Huh?"))
    }
    return .none
}

// MARK: State

public struct MainScreenState: Equatable {
    public var sidebar: SidebarState
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
    static var placeholder = MainScreenState(jid: "hello@world.org")
}

// MARK: Actions

public enum MainScreenAction: Equatable {
    case sidebar(SidebarAction)
    case unreadStack(UnreadAction)
    case chat(ConversationAction)
}

// MARK: Environment

public struct MainScreenEnvironment {
    let userStore: UserStore
    let messageStore: MessageStore
    let statusStore: StatusStore
    let securityStore: SecurityStore

    var chat: ConversationEnvironment {
        ConversationEnvironment(
            userStore: self.userStore,
            messageStore: self.messageStore,
            statusStore: self.statusStore,
            securityStore: self.securityStore
        )
    }

    public init(
        userStore: UserStore,
        messageStore: MessageStore,
        statusStore: StatusStore,
        securityStore: SecurityStore
    ) {
        self.userStore = userStore
        self.messageStore = messageStore
        self.statusStore = statusStore
        self.securityStore = securityStore
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
                    userStore: .stub,
                    messageStore: .stub,
                    statusStore: .stub,
                    securityStore: .stub
                )
            ))
        }
    }
#endif
