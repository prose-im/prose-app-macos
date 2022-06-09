//
//  Chat.swift
//  Prose
//
//  Created by Rémi Bardon on 03/03/2022.
//  Copyright © 2022 Prose. All rights reserved.
//

import ComposableArchitecture
import OrderedCollections
import ProseCoreStub
import SharedModels
import SwiftUI

// MARK: - View

struct Chat: View {
    typealias State = ChatState
    typealias Action = ChatAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    var body: some View {
        WithViewStore(self.store.scope(state: \State.messages)) { messages in
            let messages = messages.state
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(messages.keys, id: \.self) { date in
                            Section {
                                ForEach(messages[date]!, content: MessageView.init(model:))
                            } header: {
                                DaySeparator(date: date)
                                    .padding(.top)
                            }
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity)
                .onAppear {
                    if let id = messages.values.last?.last?.id {
                        scrollView.scrollTo(id, anchor: .top)
                    }
                }
            }
            .background(Color.backgroundMessage)
            .onAppear { actions.send(.onAppear) }
        }
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let chatReducer: Reducer<
    ChatState,
    ChatAction,
    ConversationEnvironment
> = Reducer { state, action, environment in
    switch action {
    case .onAppear:
        let chatId = state.chatId
        state.messages = ChatState.sectioned((environment.messageStore.messages(chatId) ?? [])
            .map { $0.toMessageViewModel(userStore: environment.userStore) })
    }

    return .none
}

// MARK: State

public struct ChatState: Equatable {
    let chatId: ChatID
    var messages: OrderedDictionary<Date, [MessageViewModel]>

    public init(chatId: ChatID, messages: OrderedDictionary<Date, [MessageViewModel]>) {
        self.chatId = chatId
        self.messages = messages
    }

    public init(chatId: ChatID, messages: [Date: [MessageViewModel]]) {
        self.init(
            chatId: chatId,
            messages: OrderedDictionary(uniqueKeys: messages.keys, values: messages.values)
        )
    }

    public init(chatId: ChatID, messages: [MessageViewModel] = []) {
        self.init(
            chatId: chatId,
            messages: Self.sectioned(messages)
        )
    }

    static func sectioned(_ messages: [MessageViewModel]) -> OrderedDictionary<Date, [MessageViewModel]> {
        let calendar = Calendar.current
        return OrderedDictionary(grouping: messages, by: { calendar.startOfDay(for: $0.timestamp) })
    }
}

// MARK: Actions

public enum ChatAction: Equatable {
    case onAppear
}

// MARK: - Previews

#if DEBUG
    import PreviewAssets
#endif

struct Chat_Previews: PreviewProvider {
    static let messages: [MessageViewModel] = (1...21)
        .map { (n: Int) -> (Int, String) in
            (n, (["A"] + Array(repeating: "long", count: (n - 1) * 4) + ["message."])
                .joined(separator: " "))
        }
        .map {
            MessageViewModel(
                senderId: "valerian@crisp.chat",
                senderName: "Valerian",
                avatar: PreviewImages.Avatars.valerian.rawValue,
                content: $0.1,
                timestamp: .now - Double($0.0) * 1_000
            )
        }

    static var previews: some View {
        Chat(store: Store(
            initialState: ChatState(
                chatId: .person(id: "valerian@crisp.chat"),
                messages: Self.messages
            ),
            reducer: chatReducer,
            environment: .stub
        ))
    }
}
