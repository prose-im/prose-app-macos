//
//  Sidebar+Footer.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import AppLocalization
import ComposableArchitecture
import SharedModels
import SwiftUI

private let l10n = L10n.Sidebar.Footer.self

// MARK: - View

/// The small bar at the bottom of the left sidebar.
struct Footer: View {
    typealias State = FooterState
    typealias Action = FooterAction

    static let height: CGFloat = 64

    let store: Store<State, Action>

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 12) {
                // User avatar
                FooterAvatar(store: self.store.scope(state: \.avatar, action: Action.avatar))

                WithViewStore(self.store, removeDuplicates: ==) { viewStore in
                    // Team name + user status
                    FooterDetails(
                        teamName: viewStore.credentials.jidString,
                        statusIcon: viewStore.statusIcon,
                        statusMessage: viewStore.statusMessage
                    )
                }
                .layoutPriority(1)

                // Quick actions button
                FooterActionMenu(store: self.store.scope(state: \.actionButton, action: Action.actionButton))
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

let footerReducer: Reducer<
    FooterState,
    FooterAction,
    Void
> = Reducer.combine([
    footerActionMenuReducer.pullback(
        state: \.actionButton,
        action: CasePath(FooterAction.actionButton),
        environment: { $0 }
    ),
    footerAvatarReducer.pullback(
        state: \.avatar,
        action: CasePath(FooterAction.avatar),
        environment: { $0 }
    ),
])

// MARK: State

struct FooterState: Equatable {
    let credentials: UserCredentials
    let teamName: String
    let statusIcon: Character
    let statusMessage: String

    var avatar: FooterAvatarState
    var actionButton: FooterActionMenuState

    init(
        credentials: UserCredentials,
        teamName: String = "Crisp",
        statusIcon: Character = "🚀",
        statusMessage: String = "Building new features.",
        avatar: FooterAvatarState = .init(avatar: .placeholder),
        actionButton: FooterActionMenuState = .init()
    ) {
        self.credentials = credentials
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

// MARK: - Previews

#if DEBUG
    import PreviewAssets

    struct Footer_Previews: PreviewProvider {
        private struct Preview: View {
            let state: Footer.State

            var body: some View {
                Footer(store: Store(
                    initialState: state,
                    reducer: footerReducer,
                    environment: ()
                ))
            }
        }

        static var previews: some View {
            let state = FooterState(credentials: "valerian@crisp.chat")
            Preview(state: state)
                .preferredColorScheme(.light)
                .previewDisplayName("Light")
            Preview(state: state)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark")
            Preview(state: state)
                .redacted(reason: .placeholder)
                .previewDisplayName("Placeholder")
        }
    }
#endif
