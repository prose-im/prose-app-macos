//
//  ChatWithBar.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import ComposableArchitecture
import SwiftUI

// MARK: - View

struct ChatWithMessageBar: View {
    typealias State = ChatWithBarState
    typealias Action = ChatWithBarAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    var body: some View {
        Chat(store: self.store.scope(state: \State.chat, action: Action.chat))
            .frame(maxWidth: .infinity)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                MessageBar(store: self.store.scope(state: \State.messageBar, action: Action.messageBar))
                    // Make footer have a higher priority, to be accessible over the scroll view
                    .accessibilitySortPriority(1)
            }
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let chatWithBarReducer: Reducer<
    ChatWithBarState,
    ChatWithBarAction,
    ConversationEnvironment
> = Reducer.combine([
    chatReducer.pullback(
        state: \ChatWithBarState.chat,
        action: CasePath(ChatWithBarAction.chat),
        environment: { $0 }
    ),
    messageBarReducer.pullback(
        state: \ChatWithBarState.messageBar,
        action: CasePath(ChatWithBarAction.messageBar),
        environment: { _ in () }
    ),
])

// MARK: State

public struct ChatWithBarState: Equatable {
    var chat: ChatState
    var messageBar: MessageBarState

    public init(
        chat: ChatState,
        messageBar: MessageBarState
    ) {
        self.chat = chat
        self.messageBar = messageBar
    }
}

// MARK: Actions

public enum ChatWithBarAction: Equatable {
    case chat(ChatAction)
    case messageBar(MessageBarAction)
}

// MARK: - Previews

#if DEBUG
    import PreviewAssets

    struct ChatWithMessageBar_Previews: PreviewProvider {
        static let messages: [MessageViewModel] = (1...21)
            .map { (n: Int) -> (Int, String) in
                (n, "Message \(n)")
            }
            .map {
                MessageViewModel(
                    senderId: "valerian@crisp.chat",
                    senderName: "Valerian",
                    avatarURL: PreviewAsset.Avatars.valerian.customURL,
                    content: $0.1,
                    timestamp: .now - Double($0.0) * 1_000
                )
            }

        static var previews: some View {
            ChatWithMessageBar(store: Store(
                initialState: ChatWithBarState(
                    chat: ChatState(
                        chatId: .person(id: "valerian@crisp.chat"),
                        messages: Self.messages
                    ),
                    messageBar: MessageBarState(firstName: "Valerian")
                ),
                reducer: chatWithBarReducer,
                environment: .stub
            ))
        }
    }
#endif
