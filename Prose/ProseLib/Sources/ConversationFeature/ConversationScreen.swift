//
//  ConversationScreen.swift
//  Prose
//
//  Created by Valerian Saliou on 11/21/21.
//

import ComposableArchitecture
import SharedModels
import SwiftUI

// MARK: - View

public struct ConversationScreen: View {
    public typealias State = ConversationState
    public typealias Action = ConversationAction

    private let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    public init(store: Store<State, Action>) {
        self.store = store
    }

    public var body: some View {
        ChatWithMessageBar(store: store.scope(state: \State.chat, action: Action.chat))
            .safeAreaInset(edge: .trailing, spacing: 0) {
                IfLetStore(self.store.scope(state: \State.info, action: Action.info)) { store in
                    HStack(spacing: 0) {
                        Divider()
                        ConversationInfoView(store: store)
                    }
                    .frame(width: 220)
                }
            }
            .toolbar(content: Toolbar.init)
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let conversationReducer: Reducer<
    ConversationState,
    ConversationAction,
    ConversationEnvironment
> = Reducer.combine([
    chatWithBarReducer.pullback(
        state: \ConversationState.chat,
        action: /ConversationAction.chat,
        environment: { _ in () }
    ),
    conversationInfoReducer.optional().pullback(
        state: \ConversationState.info,
        action: /ConversationAction.info,
        environment: { _ in () }
    ),
])

// MARK: State

public struct ConversationState: Equatable {
    var chat: ChatWithBarState
    var info: ConversationInfoState?

    init(
        chat: ChatWithBarState,
        info: ConversationInfoState
    ) {
        self.chat = chat
        self.info = info
    }

    public init(chatId: ChatID) {
        let messages = (MessageStore.shared.messages(for: chatId) ?? [])
            .map(\.toMessageViewModel)
        self.chat = ChatWithBarState(
            chat: ChatState(messages: messages),
            // TODO: Make this dynamic
            messageBar: MessageBarState(firstName: "Valerian")
        )

        switch chatId {
        case let .person(userId):
            let user = UserStore.shared.user(for: userId) ?? .init(userId: "", displayName: "", fullName: "", avatar: "")
            self.info = ConversationInfoState(user: user)
        case .group:
            print("Group info not supported yet")
            self.info = nil
        }
    }
}

// MARK: Actions

public enum ConversationAction: Equatable {
    case chat(ChatWithBarAction)
    case info(ConversationInfoAction)
}

// MARK: Environment

public struct ConversationEnvironment: Equatable {
    public init() {}
}

// MARK: - Previews

struct ConversationScreen_Previews: PreviewProvider {
    static var previews: some View {
        ConversationScreen(store: Store(
            initialState: ConversationState(chatId: .person(id: "id-alexandre")),
            reducer: conversationReducer,
            environment: ConversationEnvironment()
        ))
    }
}
