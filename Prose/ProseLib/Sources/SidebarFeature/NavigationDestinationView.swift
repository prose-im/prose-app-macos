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
    typealias State = NavigationDestinationState
    typealias Action = NavigationDestinationAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    var body: some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("")
    }

    @ViewBuilder
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
    NavigationDestinationState,
    NavigationDestinationAction,
    NavigationDestinationEnvironment
> = Reducer.combine([
    conversationReducer.pullback(
        state: /NavigationDestinationState.chat,
        action: /NavigationDestinationAction.chat,
        environment: {
            ConversationEnvironment(
                userStore: $0.userStore,
                messageStore: $0.messageStore,
                statusStore: $0.statusStore,
                securityStore: $0.securityStore
            )
        }
    ),
    unreadReducer.pullback(
        state: /NavigationDestinationState.unread,
        action: /NavigationDestinationAction.unread,
        environment: {
            UnreadEnvironment(
                userStore: $0.userStore,
                messageStore: $0.messageStore
            )
        }
    ),
])

// MARK: State

public enum NavigationDestinationState: Equatable {
    case unread(UnreadState), replies, directMessages, peopleAndGroups
    case chat(ConversationState)
}

// MARK: Actions

public enum NavigationDestinationAction: Equatable {
    case chat(ConversationAction)
    case unread(UnreadAction)
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

extension NavigationDestinationEnvironment {
    public static var stub: Self {
        Self(
            userStore: .stub,
            messageStore: .stub,
            statusStore: .stub,
            securityStore: .stub
        )
    }
}

extension SidebarEnvironment {
    public var destination: NavigationDestinationEnvironment {
        NavigationDestinationEnvironment(
            userStore: self.userStore,
            messageStore: self.messageStore,
            statusStore: self.statusStore,
            securityStore: self.securityStore
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
