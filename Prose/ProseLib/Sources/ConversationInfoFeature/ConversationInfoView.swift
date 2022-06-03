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
                    WithViewStore(self.store.scope(state: \State.identity)) { identity in
                        IdentitySection(model: identity.state)
                    }
                    QuickActionsSection(store: self.store.scope(state: \State.quickActions, action: Action.quickActions))
                }
                .padding(.horizontal)

                WithViewStore(self.store.scope(state: \State.information)) { information in
                    InformationSection(model: information.state)
                }
                WithViewStore(self.store.scope(state: \State.security)) { security in
                    SecuritySection(model: security.state)
                }
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
                quickActions: .init(),
                information: .placeholder,
                security: .placeholder
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
> = quickActionsSectionReducer.pullback(
    state: \ConversationInfoState.quickActions,
    action: /ConversationInfoAction.quickActions,
    environment: { $0 }
)

// MARK: State

public struct ConversationInfoState: Equatable {
    let identity: IdentitySectionModel
    var quickActions: QuickActionsSectionState
    let information: InformationSectionModel
    let security: SecuritySectionModel

    public init(
        identity: IdentitySectionModel,
        quickActions: QuickActionsSectionState,
        information: InformationSectionModel,
        security: SecuritySectionModel
    ) {
        self.identity = identity
        self.quickActions = quickActions
        self.information = information
        self.security = security
    }
}

// MARK: Actions

public enum ConversationInfoAction: Equatable {
    case quickActions(QuickActionsSectionAction)
}

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
                    quickActions: .init(),
                    information: .init(
                        emailAddress: "valerian@crisp.chat",
                        phoneNumber: "+33 6 12 34 56",
                        lastSeenDate: Date.now - 1_000,
                        timeZone: TimeZone(identifier: "WEST")!,
                        location: "Lisbon, Portugal",
                        statusIcon: "👨‍💻",
                        statusMessage: "Focusing on code"
                    ),
                    security: .init(
                        isIdentityVerified: true,
                        encryptionFingerprint: "V5I92"
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
