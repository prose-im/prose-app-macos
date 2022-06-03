//
//  ConversationScreen.swift
//  Prose
//
//  Created by Valerian Saliou on 11/21/21.
//

import ComposableArchitecture
import PreviewAssets
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
                WithViewStore(self.store.scope(state: \State.toolbar.isShowingInfo)) { showingInfo in
                    HStack(spacing: 0) {
                        Divider()
                        IfLetStore(self.store.scope(state: \State.info, action: Action.info)) { store in
                            ConversationInfoView(store: store)
                        } else: {
                            ConversationInfoView.placeholder
                        }
                        .frame(width: 256)
                    }
                    .frame(width: showingInfo.state ? 256 : 0, alignment: .leading)
                    .clipped()
                }
            }
            .toolbar {
                Toolbar(store: self.store.scope(state: \State.toolbar, action: Action.toolbar))
            }
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
    toolbarReducer.pullback(
        state: \ConversationState.toolbar,
        action: /ConversationAction.toolbar,
        environment: { _ in () }
    ),
    Reducer { state, action, _ in
        switch action {
        case .toolbar(.binding(\.$isShowingInfo)):
            // TODO: [Rémi Bardon] Once `ConversationInfoState` contains a lot of data,
            //       trigger an asynchronous call here, to retrieve it.
            //       Use a placeholder while waiting for the data.
            //       For now, we'll use the `User` `struct` stored at the creation of the `State`.
            if state.toolbar.isShowingInfo, state.info == nil {
                state.info = state.toolbar.user.map(ConversationInfoState.init(user:))
            }

        default:
            break
        }

        return .none
    },
])

// MARK: State

public struct ConversationState: Equatable {
    var chat: ChatWithBarState
    var info: ConversationInfoState?
    var toolbar: ToolbarState

    init(
        chat: ChatWithBarState,
        info: ConversationInfoState,
        toolbar: ToolbarState
    ) {
        self.chat = chat
        self.info = info
        self.toolbar = toolbar
    }

    public init(chatId: ChatID) {
        let messages = (MessageStore.shared.messages(for: chatId) ?? [])
            .map(\.toMessageViewModel)
        self.chat = ChatWithBarState(
            chat: ChatState(messages: messages),
            // TODO: Make this dynamic
            messageBar: MessageBarState(firstName: "Valerian")
        )

        let user: User?
        switch chatId {
        case let .person(userId):
            user = UserStore.shared.user(for: userId) ?? .init(userId: "", displayName: "", fullName: "", avatar: "")
        case .group:
            print("Group info not supported yet")
            user = nil
        }

        self.info = nil

        // TODO: [Rémi Bardon] We should remember the `showingInfo` setting, to avoid hiding if every time
        self.toolbar = ToolbarState(user: user, showingInfo: false)
    }
}

// MARK: Actions

public enum ConversationAction: Equatable {
    case chat(ChatWithBarAction)
    case info(ConversationInfoAction)
    case toolbar(ToolbarAction)
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
