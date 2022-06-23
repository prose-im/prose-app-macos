//
//  ConversationScreen.swift
//  Prose
//
//  Created by Valerian Saliou on 11/21/21.
//

import ComposableArchitecture
import ConversationInfoFeature
import ProseCoreTCA
import SharedModels
import SwiftUI
import TcaHelpers

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
        Chat(store: self.store.scope(state: \State.chat).actionless)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                MessageBar(store: self.store.scope(state: \.messageBar, action: Action.messageBar))
                    // Make footer have a higher priority, to be accessible over the scroll view
                    .accessibilitySortPriority(1)
            }
            .onAppear { actions.send(.onAppear) }
            .onDisappear { actions.send(.onDisappear) }
            .safeAreaInset(edge: .trailing, spacing: 0) {
                WithViewStore(self.store.scope(state: \State.toolbar.isShowingInfo)) { showingInfo in
                    HStack(spacing: 0) {
                        Divider()
                        IfLetStore(self.store.scope(state: \.info, action: Action.info)) { store in
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
                Toolbar(store: self.store.scope(state: \.toolbar, action: Action.toolbar))
            }
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

enum ConversationEffectToken: Hashable, CaseIterable {
    case observeMessages
}

public let conversationReducer: Reducer<
    ConversationState,
    ConversationAction,
    ConversationEnvironment
> = Reducer.combine([
    messageBarReducer.pullback(
        state: \ConversationState.messageBar,
        action: CasePath(ConversationAction.messageBar),
        environment: { _ in () }
    ),
    conversationInfoReducer.optional().pullback(
        state: \ConversationState.info,
        action: CasePath(ConversationAction.info),
        environment: { _ in () }
    ),
    toolbarReducer.pullback(
        state: \ConversationState.toolbar,
        action: CasePath(ConversationAction.toolbar),
        environment: { _ in () }
    ),
    Reducer { state, action, environment in
        switch action {
        case .onAppear:
            return environment.proseClient.messagesInChat(state.chatId)
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .map(ConversationAction.messagesDidChange)
                .cancellable(id: ConversationEffectToken.observeMessages, cancelInFlight: true)

        case .onDisappear:
            return .cancel(token: ConversationEffectToken.self)

        case let .messageBar(.textField(.send(messageContent))):
            // Ignore the error for now. There is no error handling in the library so far.
            return environment.proseClient.sendMessage(state.chatId, messageContent)
                .ignoreOutput()
                .eraseToEffect()
                .fireAndForget()

        case let .messagesDidChange(messages):
            state.messages = messages
            return .none

        case .toolbar(.binding(\.$isShowingInfo)):
            if state.toolbar.isShowingInfo, state.info == nil {
                state.info = .demo
            }
            return .none

        case .info, .toolbar, .messageBar:
            return .none
        }
    },
])

// MARK: State

public struct ConversationState: Equatable {
    let chatId: JID
    var info: ConversationInfoState?
    var toolbar: ToolbarState
    var messageBar: MessageBarState
    var messages = [Message]()

    public init(chatId: JID) {
        self.chatId = chatId
        self.toolbar = .init(user: .init(
            jid: chatId,
            displayName: chatId.jidString,
            fullName: "John Doe",
            avatar: nil,
            jobTitle: "Chatbot",
            company: "Acme Inc.",
            emailAddress: "chatbot@prose.org",
            phoneNumber: "0000000",
            location: "The Internets"
        ))
        self.messageBar = .init(textField: .init(recipient: chatId.jidString))
    }
}

extension ConversationState {
    var chat: ChatState {
        .init(messages: self.messages)
    }
}

// MARK: Actions

public enum ConversationAction: Equatable {
    case onAppear
    case onDisappear

    case messagesDidChange([Message])

    case info(ConversationInfoAction)
    case toolbar(ToolbarAction)
    case messageBar(MessageBarAction)
}

// MARK: Environment

public struct ConversationEnvironment {
    var proseClient: ProseClient
    var mainQueue: AnySchedulerOf<DispatchQueue>

    public init(
        proseClient: ProseClient,
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.proseClient = proseClient
        self.mainQueue = mainQueue
    }
}

// MARK: - Previews

struct ConversationScreen_Previews: PreviewProvider {
    private struct Preview: View {
        var body: some View {
            ConversationScreen(store: Store(
                initialState: ConversationState(chatId: JID(rawValue: "alexandre@crisp.chat")),
                reducer: conversationReducer,
                environment: .init(proseClient: .noop, mainQueue: .main)
            ))
            .previewLayout(.sizeThatFits)
        }
    }

    static var previews: some View {
        Preview()
        Preview()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark mode")
        Preview()
            .redacted(reason: .placeholder)
            .previewDisplayName("Placeholder")
    }
}
