//
//  Sidebar+Footer.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import AppLocalization
import ComposableArchitecture
import PreviewAssets
import SharedModels
import SwiftUI

private let l10n = L10n.Sidebar.Footer.self

// MARK: - View

/// The small bar at the bottom of the left sidebar.
struct Footer: View {
    typealias State = (FooterState, UserCredentials)
    typealias Action = FooterAction

    static let height: CGFloat = 64

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 12) {
                // User avatar
                FooterAvatar(store: self.store.scope(state: \State.0.avatar, action: Action.avatar))

                WithViewStore(self.store, removeDuplicates: ==) { viewStore in
                    // Team name + user status
                    FooterDetails(
                        teamName: viewStore.1.jid,
                        statusIcon: viewStore.0.statusIcon,
                        statusMessage: viewStore.0.statusMessage
                    )
                }
                .layoutPriority(1)

                // Quick actions button
                FooterActionMenu(store: self.store.scope(state: \.0.actionButton, action: Action.actionButton))
            }
            .padding(.leading, 20.0)
            .padding(.trailing, 14.0)
            .frame(maxHeight: 64)
        }
        .frame(height: Self.height)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(l10n.label)
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let footerReducer: Reducer<
    FooterState,
    FooterAction,
    Void
> = Reducer.combine([
    footerActionMenuReducer.pullback(
        state: \FooterState.actionButton,
        action: /FooterAction.actionButton,
        environment: { $0 }
    ),
    footerAvatarReducer.pullback(
        state: \FooterState.avatar,
        action: /FooterAction.avatar,
        environment: { $0 }
    ),
])

// MARK: State

public struct FooterState: Equatable {
    let teamName: String
    let statusIcon: Character
    let statusMessage: String

    var avatar: FooterAvatarState
    var actionButton: FooterActionMenuState

    public init(
        teamName: String = "Crisp",
        statusIcon: Character = "🚀",
        statusMessage: String = "Building new features.",
        avatar: FooterAvatarState,
        actionButton: FooterActionMenuState = .init()
    ) {
        self.teamName = teamName
        self.statusIcon = statusIcon
        self.statusMessage = statusMessage
        self.avatar = avatar
        self.actionButton = actionButton
    }
}

// MARK: Actions

public enum FooterAction: Equatable {
    case avatar(FooterAvatarAction)
    case actionButton(FooterActionMenuAction)
}
