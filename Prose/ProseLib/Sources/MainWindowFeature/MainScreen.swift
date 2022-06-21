//
//  MainScreen.swift
//  Prose
//
//  Created by Rémi Bardon on 01/06/2022.
//

import AddressBookFeature
import ComposableArchitecture
import ConversationFeature
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
        environment: { _ in .stub }
    ),
    Reducer { state, action, _ in
        switch action {
        case .sidebar(.selection(.unreadStack)):
            state.route = .unreadStack(.init())
            return .none

        case .sidebar(.selection(.replies)):
            state.route = .replies
            return .none

        case .sidebar(.selection(.directMessages)):
            state.route = .directMessages
            return .none

        case .sidebar(.selection(.peopleAndGroups)):
            state.route = .peopleAndGroups
            return .none

        case let .sidebar(.selection(.chat(jid))):
            state.route = .chat(.init(chatId: .person(id: jid), recipient: "Huh?"))
            return .none

        case .sidebar, .unreadStack, .chat:
            return .none
        }
    },
])

// MARK: State

public struct MainScreenState: Equatable {
    var sidebar: SidebarState
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
    public init() {}
}

// MARK: - Previews

#if DEBUG
    import PreviewAssets

    internal struct MainWindow_Previews: PreviewProvider {
        static var previews: some View {
            MainScreen(store: Store(
                initialState: MainScreenState(jid: "preview@prose.org"),
                reducer: mainWindowReducer,
                environment: MainScreenEnvironment()
            ))
        }
    }
#endif
