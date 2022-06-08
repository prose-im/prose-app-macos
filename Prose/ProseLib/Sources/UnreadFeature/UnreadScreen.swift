//
//  UnreadScreen.swift
//  Prose
//
//  Created by Rémi Bardon on 27/03/2022.
//

import ComposableArchitecture
import ConversationFeature
import OrderedCollections
import PreviewAssets
import ProseCoreStub
import ProseUI
import SharedModels
import SwiftUI

// MARK: - View

public struct UnreadScreen: View {
    public typealias State = UnreadState
    public typealias Action = UnreadAction

    public let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    public init(store: Store<State, Action>) {
        self.store = store
    }

    public var body: some View {
        content()
            .background(Color.backgroundMessage)
            .toolbar(content: Toolbar.init)
            .onAppear { actions.send(.onAppear) }
    }

    @ViewBuilder
    private func content() -> some View {
        WithViewStore(self.store.scope(state: \State.messages.isEmpty)) { noMessage in
            if noMessage.state {
                self.nothing()
            } else {
                self.list()
            }
        }
    }

    @ViewBuilder
    private func nothing() -> some View {
        Text("Looks like you read everything 🎉")
            .font(.largeTitle.bold())
            .foregroundColor(.secondary)
            .padding()
    }

    @ViewBuilder
    private func list() -> some View {
        ScrollView {
            VStack(spacing: 24) {
                WithViewStore(self.store) { viewStore in
                    ForEach(viewStore.state.messages, id: \.chatId, content: UnreadSection.init(model:))
                }
            }
            .padding(24)
        }
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let unreadReducer: Reducer<
    UnreadState,
    UnreadAction,
    UnreadEnvironment
> = Reducer { state, action, environment in
    switch action {
    case .onAppear:
        guard state.messages.isEmpty else { return .none }

        return Effect.task(priority: .high) {
            let messages = environment.messageStore.unreadMessages()
                .map { (chatId, messages) -> UnreadSectionModel in
                    let messages = messages.map { $0.toMessageViewModel(userStore: environment.userStore) }
                    
                    let chatTitle: String
                    switch chatId {
                    case let .person(id: jid):
                        chatTitle = environment.userStore.user(for: jid)?.fullName ?? "Unknown"
                    case let .group(id: groupId):
                        chatTitle = String(describing: groupId)
                    }
                    
                    return UnreadSectionModel(
                        chatId: chatId,
                        chatTitle: chatTitle,
                        messages: messages
                    )
                }
            
            return .didLoadMessages(messages)
        }
        .receive(on: RunLoop.main)
        .eraseToEffect()

    case let .didLoadMessages(messages):
        state.messages = messages
    }

    return .none
}

// MARK: State

public struct UnreadState: Equatable {
    var messages: [UnreadSectionModel]

    public init(messages: [UnreadSectionModel] = []) {
        self.messages = messages
    }
}

// MARK: Actions

public enum UnreadAction: Equatable {
    case onAppear
    case didLoadMessages([UnreadSectionModel])
}

// MARK: Environment

public struct UnreadEnvironment {
    let userStore: UserStore
    let messageStore: MessageStore

    public init(
        userStore: UserStore,
        messageStore: MessageStore
    ) {
        self.userStore = userStore
        self.messageStore = messageStore
    }
}

// MARK: - Previews

struct UnreadScreen_Previews: PreviewProvider {
    private struct Preview: View {
        var body: some View {
            content(state: .init(messages: [
                .init(
                    chatId: .person(id: "valerian@crisp.chat"),
                    chatTitle: "Valerian",
                    messages: [
                        MessageViewModel(
                            senderId: "baptiste@crisp.chat",
                            senderName: "Baptiste",
                            avatar: PreviewImages.Avatars.baptiste.rawValue,
                            content: "They forgot to ship the package.",
                            timestamp: Date() - 2_800
                        ),
                        MessageViewModel(
                            senderId: "valerian@crisp.chat",
                            senderName: "Valerian",
                            avatar: PreviewImages.Avatars.valerian.rawValue,
                            content: "Okay, I see. Thanks. I will contact them whenever they get back online. 🤯",
                            timestamp: Date() - 3_000
                        ),
                    ]
                ),
                .init(
                    chatId: .person(id: "julien@thefamily.com"),
                    chatTitle: "Julien",
                    messages: [
                        MessageViewModel(
                            senderId: "baptiste@crisp.chat",
                            senderName: "Baptiste",
                            avatar: PreviewImages.Avatars.baptiste.rawValue,
                            content: "Can I initiate a deployment of the Vue app?",
                            timestamp: Date() - 9_000
                        ),
                        MessageViewModel(
                            senderId: "julien@thefamily.com",
                            senderName: "Julien",
                            avatar: PreviewImages.Avatars.julien.rawValue,
                            content: "Yes, it's ready. 3 new features are shipping! 😀",
                            timestamp: Date() - 10_000
                        ),
                    ]
                ),
                .init(
                    chatId: .group(id: "constellation"),
                    chatTitle: "Julien",
                    messages: [
                        MessageViewModel(
                            senderId: "baptiste@crisp.chat",
                            senderName: "Baptiste",
                            avatar: PreviewImages.Avatars.baptiste.rawValue,
                            content: "⚠️ I'm performing a change of the server IP definitions. Slight outage expected.",
                            timestamp: Date() - 90_000
                        ),
                        MessageViewModel(
                            senderId: "constellation-health@crisp.chat",
                            senderName: "constellation-health",
                            avatar: PreviewImages.Avatars.constellationHealth.rawValue,
                            content: "🆘 socket-1.sgp.atlas.net.crisp.chat - Got HTTP status: \"503 or invalid body\"",
                            timestamp: Date() - 100_000
                        ),
                    ]
                )
            ]))
            content(state: .init(messages: []))
        }

        @ViewBuilder
        private func content(state: UnreadState) -> some View {
            UnreadScreen(store: Store(
                initialState: state,
                reducer: unreadReducer,
                environment: UnreadEnvironment(
                    userStore: .stub,
                    messageStore: .stub
                )
            ))
        }
    }

    static var previews: some View {
        Preview()
            .preferredColorScheme(.light)
            .previewDisplayName("Light")

        Preview()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark")
    }
}
