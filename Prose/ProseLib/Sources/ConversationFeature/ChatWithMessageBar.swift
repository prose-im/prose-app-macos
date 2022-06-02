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

    init(store: Store<State, Action>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(self.store) { viewStore in
            Chat(model: viewStore.chatViewModel)
                .frame(maxWidth: .infinity)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    MessageBar(
                        firstName: "Valerian"
                    )
                    // Make footer have a higher priority, to be accessible over the scroll view
                    .accessibilitySortPriority(1)
                }
        }
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let chatWithBarReducer: Reducer<
    ChatWithBarState,
    ChatWithBarAction,
    Void
> = Reducer.empty

// MARK: State

public struct ChatWithBarState: Equatable {
    let chatViewModel: ChatViewModel

    public init(
        chatViewModel: ChatViewModel
    ) {
        self.chatViewModel = chatViewModel
    }
}

// MARK: Actions

public enum ChatWithBarAction: Equatable {}

// MARK: - Previews

#if DEBUG
    import PreviewAssets
#endif

struct ChatWithMessageBar_Previews: PreviewProvider {
    static let messages: [MessageViewModel] = (1...21)
        .map { (n: Int) -> (Int, String) in
            (n, "Message \(n)")
        }
        .map {
            MessageViewModel(
                senderId: "id-valerian",
                senderName: "Valerian",
                avatar: PreviewImages.Avatars.valerian.rawValue,
                content: $0.1,
                timestamp: .now - Double($0.0) * 1_000
            )
        }

    static var previews: some View {
        ChatWithMessageBar(store: Store(
            initialState: ChatWithBarState(
                chatViewModel: .init(messages: Self.messages)
            ),
            reducer: chatWithBarReducer,
            environment: ()
        ))
    }
}
