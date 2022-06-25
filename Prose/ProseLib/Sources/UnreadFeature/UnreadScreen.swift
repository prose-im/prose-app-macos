//
//  UnreadScreen.swift
//  Prose
//
//  Created by Rémi Bardon on 27/03/2022.
//

import Assets
import ComposableArchitecture
import ConversationFeature
import ProseCoreTCA
import ProseUI
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
> = Reducer { _, action, _ in
    switch action {
    case .onAppear:
        return .none
    }
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
    public init() {}
}
