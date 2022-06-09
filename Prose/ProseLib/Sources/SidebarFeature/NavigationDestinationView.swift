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

    @ViewBuilder
    private func content() -> some View {
        SwitchStore(self.store) {
            CaseLet(state: /State.chat, action: Action.chat, then: ConversationScreen.init(store:))
            Default {
                WithViewStore(self.store) { viewStore in
                    switch viewStore.state {
                    case .chat:
                        // Already supported
                        EmptyView()
                    case .unread:
                        UnreadScreen(model: .init(
                            messages: MessageStore.shared.unreadMessages().mapValues { $0.map(\.toMessageViewModel) }
                        ))
                        .groupBoxStyle(.spotlight)
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
    SidebarRoute,
    NavigationDestinationAction,
    NavigationDestinationEnvironment
> = conversationReducer.pullback(
    state: /SidebarRoute.chat,
    action: /NavigationDestinationAction.chat,
    environment: { _ in ConversationEnvironment() }
)

// MARK: Actions

public enum NavigationDestinationAction: Equatable {
    case chat(ConversationAction)
}

// MARK: Environment

public struct NavigationDestinationEnvironment {
    public init() {}
}

// MARK: - Previews

struct NavigationDestinationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationDestinationView(store: Store(
            initialState: .chat(.init(chatId: .person(id: "valerian@crisp.chat"))),
            reducer: navigationDestinationReducer,
            environment: NavigationDestinationEnvironment()
        ))
    }
}
