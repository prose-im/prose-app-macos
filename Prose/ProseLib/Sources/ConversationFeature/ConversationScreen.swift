//
//  ConversationScreen.swift
//  Prose
//
//  Created by Valerian Saliou on 11/21/21.
//

import ComposableArchitecture
import ConversationInfoFeature
import PreviewAssets
import ProseCoreStub
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
            .onAppear { actions.send(.onAppear) }
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
        environment: { $0 }
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
    Reducer { state, action, environment in
        switch action {
        case .onAppear:
            guard state.toolbar.user == nil else { return .none }

            let user: User?
            switch state.chatId {
            case let .person(jid):
                user = environment.userStore.user(jid)
            case .group:
                print("Group info not supported yet")
                user = nil
            }

            // TODO: [Rémi Bardon] We should remember the `showingInfo` setting, to avoid hiding if every time
            state.toolbar = ToolbarState(user: user, showingInfo: false)

        case .toolbar(.binding(\.$isShowingInfo)):
            // TODO: [Rémi Bardon] Once `ConversationInfoState` contains a lot of data,
            //       trigger an asynchronous call here, to retrieve it.
            //       Use a placeholder while waiting for the data.
            if state.toolbar.isShowingInfo, state.info == nil {
                let user: User?
                let status: OnlineStatus?
                let lastSeenDate: Date?
                let timeZone: TimeZone?
                let statusLine: (Character, String)?
                let isIdentityVerified: Bool
                let encryptionFingerprint: String?

                switch state.chatId {
                case let .person(jid):
                    user = environment.userStore.user(jid)
                    status = environment.statusStore.onlineStatus(jid)
                    lastSeenDate = environment.statusStore.lastSeenDate(jid)
                    timeZone = environment.statusStore.timeZone(jid)
                    statusLine = environment.statusStore.statusLine(jid)
                    isIdentityVerified = environment.securityStore.isIdentityVerified(jid)
                    encryptionFingerprint = environment.securityStore.encryptionFingerprint(jid)
                case .group:
                    print("Group info not supported yet")
                    user = nil
                    status = nil
                    lastSeenDate = nil
                    timeZone = nil
                    statusLine = nil
                    isIdentityVerified = false
                    encryptionFingerprint = nil
                }

                if let user = user,
                   let status = status,
                   let lastSeenDate = lastSeenDate,
                   let timeZone = timeZone,
                   let statusLine = statusLine
                {
                    state.info = ConversationInfoState(
                        identity: .init(from: user, status: status),
                        quickActions: .init(),
                        information: .init(
                            from: user,
                            lastSeenDate: lastSeenDate,
                            timeZone: timeZone,
                            statusIcon: statusLine.0,
                            statusMessage: statusLine.1
                        ),
                        security: .init(
                            isIdentityVerified: isIdentityVerified,
                            encryptionFingerprint: encryptionFingerprint
                        ),
                        actions: .init()
                    )
                }
            }

        default:
            break
        }

        return .none
    },
])

// MARK: State

public struct ConversationState: Equatable {
    public let chatId: ChatID
    var chat: ChatWithBarState
    var info: ConversationInfoState?
    var toolbar: ToolbarState

    public init(
        chatId: ChatID,
        chat: ChatWithBarState? = nil,
        info: ConversationInfoState? = nil,
        toolbar: ToolbarState? = nil
    ) {
        self.chatId = chatId
        self.chat = chat ?? ChatWithBarState(
            chat: ChatState(chatId: chatId),
            // TODO: Make this dynamic
            messageBar: MessageBarState(firstName: "Valerian")
        )
        self.info = info
        self.toolbar = toolbar ?? .init(user: nil)
    }
}

// MARK: Actions

public enum ConversationAction: Equatable {
    case onAppear
    case chat(ChatWithBarAction)
    case info(ConversationInfoAction)
    case toolbar(ToolbarAction)
}

// MARK: Environment

public struct ConversationEnvironment {
    let userStore: UserStore
    let messageStore: MessageStore
    let statusStore: StatusStore
    let securityStore: SecurityStore

    public init(
        userStore: UserStore,
        messageStore: MessageStore,
        statusStore: StatusStore,
        securityStore: SecurityStore
    ) {
        self.userStore = userStore
        self.messageStore = messageStore
        self.statusStore = statusStore
        self.securityStore = securityStore
    }
}

public extension ConversationEnvironment {
    static var stub: ConversationEnvironment {
        ConversationEnvironment(
            userStore: .stub,
            messageStore: .stub,
            statusStore: .stub,
            securityStore: .stub
        )
    }
}

// MARK: - Previews

struct ConversationScreen_Previews: PreviewProvider {
    private struct Preview: View {
        var body: some View {
            ConversationScreen(store: Store(
                initialState: ConversationState(chatId: .person(id: "alexandre@crisp.chat")),
                reducer: conversationReducer,
                environment: .stub
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
