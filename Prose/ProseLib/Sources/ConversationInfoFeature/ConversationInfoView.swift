//
//  ConversationInfoView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import ComposableArchitecture
import ProseCoreStub
import SwiftUI

// MARK: - View

public struct ConversationInfoView: View {
    public typealias State = ConversationInfoState
    public typealias Action = ConversationInfoAction

    private let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    public init(store: Store<State, Action>) {
        self.store = store
    }

    public var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    WithViewStore(self.store) { viewStore in
                        IdentitySection(model: viewStore.identity)
                    }
                    QuickActionsSection()
                }
                .padding(.horizontal)

                InformationSection()
                SecuritySection()
                ActionsSection()
            }
            .padding(.vertical)
        }
        .groupBoxStyle(SectionGroupStyle())
        .background(.background)
    }
}

public extension ConversationInfoView {
    static var placeholder: some View {
        ConversationInfoView(store: Store(
            initialState: ConversationInfoState(
                identity: .init(from: .placeholder, status: .offline),
                user: .placeholder
            ),
            reducer: Reducer.empty,
            environment: ()
        ))
        .redacted(reason: .placeholder)
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let conversationInfoReducer: Reducer<
    ConversationInfoState,
    ConversationInfoAction,
    Void
> = Reducer.empty

// MARK: State

public struct ConversationInfoState: Equatable {
    let identity: IdentitySectionModel
    let user: User

    public init(
        identity: IdentitySectionModel,
        user: User
    ) {
        self.identity = identity
        self.user = user
    }
}

// MARK: Actions

public enum ConversationInfoAction: Equatable {}

// MARK: - Previews

#if DEBUG
    import PreviewAssets
#endif

internal struct ConversationInfoView_Previews: PreviewProvider {
    private struct Preview: View {
        var body: some View {
            ConversationInfoView(store: Store(
                initialState: ConversationInfoState(
                    identity: .init(
                        avatar: PreviewImages.Avatars.valerian.rawValue,
                        fullName: "Valerian Saliou",
                        status: .online,
                        jobTitle: "CTO",
                        company: "Crisp"
                    ),
                    user: .init(
                        userId: "valerian@prose.org",
                        displayName: "Valerian",
                        fullName: "Valerian Saliou",
                        avatar: PreviewImages.Avatars.valerian.rawValue,
                        jobTitle: "CTO",
                        company: "Crisp"
                    )
                ),
                reducer: conversationInfoReducer,
                environment: ()
            ))
            .frame(width: 220, height: 720)
        }
    }

    static var previews: some View {
        Preview()
            .previewDisplayName("Normal")
        Preview()
            .previewDisplayName("Real placeholder")
        ConversationInfoView.placeholder
            .previewDisplayName("Simple placeholder")
    }
}
