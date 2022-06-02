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

// swiftlint:disable file_types_order

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
                WithViewStore(self.store.scope(state: \State.0)) { viewStore in
                    // User avatar
                    FooterAvatar(
                        avatar: viewStore.avatar,
                        status: viewStore.status
                    )
                }

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
                FooterActionMenu(store: self.store.scope(state: \State.0.actionButton, action: Action.actionButton))
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

// MARK: - The Composabe Architecture

// MARK: Reducer

private let footerCoreReducer: Reducer<
    FooterState,
    FooterAction,
    Void
> = Reducer { _, action, _ in
    switch action {
    case .actionButton:
        break

    default:
        // TODO: [Rémi Bardon] Handle actions
        assertionFailure("Received unhandled action: \(String(describing: action))")
    }

    return .none
}

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
    footerCoreReducer,
])

// MARK: State

public struct FooterState: Equatable {
    let avatar: String
    let status: OnlineStatus
    let teamName: String
    let statusIcon: Character
    let statusMessage: String

    var actionButton: FooterActionMenuState

    public init(
        avatar: String = PreviewImages.Avatars.valerian.rawValue,
        status: OnlineStatus = .online,
        teamName: String = "Crisp",
        statusIcon: Character = "🚀",
        statusMessage: String = "Building new features.",
        actionButton: FooterActionMenuState = .init()
    ) {
        self.avatar = avatar
        self.status = status
        self.teamName = teamName
        self.statusIcon = statusIcon
        self.statusMessage = statusMessage
        self.actionButton = actionButton
    }
}

// MARK: Actions

public enum FooterAction: Equatable {
    // Avatar
    case updateMoodTapped
    case changeAvailabilityTapped(Availability)
    case pauseNotificationsTapped
    case editProfileTapped
    case accountSettingsTapped
    case offlineModeTapped
    case signOutTapped
    // Action button
    case actionButton(FooterActionMenuAction)
}
