//
//  UnreadScreen.swift
//  Prose
//
//  Created by Rémi Bardon on 27/03/2022.
//

import Assets
import ComposableArchitecture
import ConversationFeature
import ProseCoreStub
import ProseUI
import SharedModels
import SwiftUI

// MARK: - View

public struct UnreadScreen: View {
    public typealias State = UnreadState
    public typealias Action = UnreadAction

    private let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    public init(store: Store<State, Action>) {
        self.store = store
    }

    public var body: some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Colors.Background.message.color)
            .toolbar(content: Toolbar.init)
            .onAppear { actions.send(.onAppear) }
            .groupBoxStyle(.spotlight)
    }

    private func content() -> some View {
        WithViewStore(self.store.scope(state: \State.messages.isEmpty)) { noMessage in
            if noMessage.state {
                self.nothing()
            } else {
                self.list()
            }
        }
    }

    private func nothing() -> some View {
        Text("Looks like you read everything 🎉")
            .font(.largeTitle.bold())
            .foregroundColor(.secondary)
            .padding()
            .unredacted()
    }

    private func list() -> some View {
        ScrollView {
            VStack(spacing: 24) {
                WithViewStore(self.store.scope(state: \State.messages)) { messages in
                    ForEach(messages.state, id: \.chatId, content: UnreadSection.init(model:))
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

        state.messages = environment.messageStore.unreadMessages()
            .map { chatId, messages in
                let messages = messages.map { $0.toMessageViewModel(userStore: environment.userStore) }

                let chatTitle: String
                switch chatId {
                case let .person(id: jid):
                    chatTitle = environment.userStore.user(jid)?.fullName ?? "Unknown"
                case let .group(id: groupId):
                    chatTitle = String(describing: groupId)
                }

                return UnreadSectionModel(
                    chatId: chatId,
                    chatTitle: chatTitle,
                    messages: messages
                )
            }
    }

    return .none
}

// MARK: State

public struct UnreadState: Equatable {
    var messages: [UnreadSectionModel]

    public init(
        messages: [UnreadSectionModel] = []
    ) {
        self.messages = messages
    }
}

// MARK: Actions

public enum UnreadAction: Equatable {
    case onAppear
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

public extension UnreadEnvironment {
    static var stub: UnreadEnvironment {
        UnreadEnvironment(
            userStore: .stub,
            messageStore: .stub
        )
    }
}

// MARK: - Previews

#if DEBUG
    import PreviewAssets

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
                                avatarURL: PreviewAsset.Avatars.baptiste.customURL,
                                content: "They forgot to ship the package.",
                                timestamp: Date() - 2_800
                            ),
                            MessageViewModel(
                                senderId: "valerian@crisp.chat",
                                senderName: "Valerian",
                                avatarURL: PreviewAsset.Avatars.valerian.customURL,
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
                                avatarURL: PreviewAsset.Avatars.baptiste.customURL,
                                content: "Can I initiate a deployment of the Vue app?",
                                timestamp: Date() - 9_000
                            ),
                            MessageViewModel(
                                senderId: "julien@thefamily.com",
                                senderName: "Julien",
                                avatarURL: PreviewAsset.Avatars.julien.customURL,
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
                                avatarURL: PreviewAsset.Avatars.baptiste.customURL,
                                content: "⚠️ I'm performing a change of the server IP definitions. Slight outage expected.",
                                timestamp: Date() - 90_000
                            ),
                            MessageViewModel(
                                senderId: "constellation-health@crisp.chat",
                                senderName: "constellation-health",
                                avatarURL: PreviewAsset.Avatars.constellationHealth.customURL,
                                content: "🆘 socket-1.sgp.atlas.net.crisp.chat - Got HTTP status: \"503 or invalid body\"",
                                timestamp: Date() - 100_000
                            ),
                        ]
                    ),
                ]))
                content(state: .init(messages: .init()))
            }

            private func content(state: UnreadState) -> some View {
                UnreadScreen(store: Store(
                    initialState: state,
                    reducer: Reducer.empty,
                    environment: UnreadEnvironment.stub
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
            Preview()
                .redacted(reason: .placeholder)
                .previewDisplayName("Placeholder")
        }
    }
#endif
