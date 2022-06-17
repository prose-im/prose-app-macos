//
//  NavigationDestinationView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/15/21.
//

import AddressBookFeature
import ComposableArchitecture
import ConversationFeature
import ProseCoreStub
import ProseUI
import SwiftUI
import UnreadFeature

// MARK: - View

/// The view displayed in the middle of the screen when a row is selected in the left sidebar.
struct NavigationDestinationView: View {
    typealias State = SidebarRoute
    typealias Action = NavigationDestinationAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    var body: some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("")
    }

    private func content() -> some View {
        SwitchStore(self.store) {
            CaseLet(state: /State.chat, action: Action.chat, then: ConversationScreen.init(store:))
            CaseLet(state: /State.unread, action: Action.unread) { store in
                UnreadScreen(store: store)
                    .groupBoxStyle(.spotlight)
            }
            Default {
                WithViewStore(self.store) { viewStore in
                    switch viewStore.state {
                    case .chat, .unread:
                        // Already supported
                        EmptyView()
                    case .peopleAndGroups:
                        AddressBookScreen()
                    case let value:
                        Text("\(String(describing: value)) (not supported yet)")
                            .unredacted()
                            .toolbar(content: CommonToolbar.init)
                    }
                }
            }
        }
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let navigationDestinationReducer: Reducer<
    SidebarRoute,
    NavigationDestinationAction,
    NavigationDestinationEnvironment
> = Reducer.combine([
    unreadReducer.pullback(
        state: /SidebarRoute.unread,
        action: /NavigationDestinationAction.unread,
        environment: { $0.unread }
    ),
    conversationReducer.pullback(
        state: /SidebarRoute.chat,
        action: /NavigationDestinationAction.chat,
        environment: { $0.chat }
    ),
])

// MARK: Actions

public enum NavigationDestinationAction: Equatable {
    case unread(UnreadAction)
    case chat(ConversationAction)
}

// MARK: Environment

public struct NavigationDestinationEnvironment {
    let userStore: UserStore
    let messageStore: MessageStore
    let statusStore: StatusStore
    let securityStore: SecurityStore

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

public extension NavigationDestinationEnvironment {
    static var stub: NavigationDestinationEnvironment {
        NavigationDestinationEnvironment(
            userStore: .stub,
            messageStore: .stub,
            statusStore: .stub,
            securityStore: .stub
        )
    }
}

public extension NavigationDestinationEnvironment {
    var chat: ConversationEnvironment {
        ConversationEnvironment(
            userStore: self.userStore,
            messageStore: self.messageStore,
            statusStore: self.statusStore,
            securityStore: self.securityStore
        )
    }

    var unread: UnreadEnvironment {
        UnreadEnvironment(
            userStore: self.userStore,
            messageStore: self.messageStore
        )
    }
}

// MARK: - Previews

struct NavigationDestinationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationDestinationView(store: Store(
            initialState: .chat(.init(chatId: .person(id: "valerian@crisp.chat"))),
            reducer: navigationDestinationReducer,
            environment: .stub
        ))
    }
}
