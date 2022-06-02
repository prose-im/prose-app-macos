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
        WithViewStore(self.store) { viewStore in
            ChatWithMessageBar(chatViewModel: viewStore.chatViewModel)
                .safeAreaInset(edge: .trailing, spacing: 0) {
                    HStack(spacing: 0) {
                        Divider()
                        ConversationInfoView(
                            avatar: viewStore.sender.avatar,
                            name: viewStore.sender.displayName
                        )
                    }
                    .frame(width: 220)
                }
                .toolbar(content: Toolbar.init)
        }
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let conversationReducer: Reducer<
    ConversationState,
    ConversationAction,
    ConversationEnvironment
> = Reducer { _, action, _ in
    switch action {}

    return .none
}

// MARK: State

public struct ConversationState: Equatable {
    let chatId: ChatID
    let sender: User
    let chatViewModel: ChatViewModel

    init(
        chatId: ChatID,
        sender: User,
        chatViewModel: ChatViewModel
    ) {
        self.chatId = chatId
        self.sender = sender
        self.chatViewModel = chatViewModel
    }

    public init(chatId: ChatID) {
        self.chatId = chatId
        switch chatId {
        case let .person(userId):
            self.sender = UserStore.shared.user(for: userId) ?? .init(userId: "", displayName: "", fullName: "", avatar: "")
        case .group:
            fatalError("Not supported yet")
        }
        let messages = (MessageStore.shared.messages(for: chatId) ?? [])
            .map(\.toMessageViewModel)
        self.chatViewModel = .init(messages: messages)
    }
}

// MARK: Actions

public enum ConversationAction: Equatable {}

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
