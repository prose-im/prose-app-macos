//
//  ConversationInfoView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import ComposableArchitecture
import SwiftUI

// MARK: - View

struct ConversationInfoView: View {
    struct SectionGroupStyle: GroupBoxStyle {
        private static let sidesPadding: CGFloat = 15

        func makeBody(configuration: Configuration) -> some View {
            VStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    configuration.label
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color.primary.opacity(0.25))
                        .padding(.horizontal, Self.sidesPadding)
                        .unredacted()

                    Divider()
                }

                configuration.content
                    .padding(.horizontal, Self.sidesPadding)
            }
        }
    }

    typealias State = ConversationInfoState
    typealias Action = ConversationInfoAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    WithViewStore(self.store) { viewStore in
                        IdentitySection(
                            avatar: viewStore.user.avatar,
                            name: viewStore.user.fullName
                        )
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

extension ConversationInfoView {
    static var placeholder: some View {
        ConversationInfoView(store: Store(
            initialState: ConversationInfoState(
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
    let user: User

    public init(
        user: User
    ) {
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
                    user: .init(
                        userId: "valerian@prose.org",
                        displayName: "Valerian",
                        fullName: "valerian Saliou",
                        avatar: PreviewImages.Avatars.valerian.rawValue
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
