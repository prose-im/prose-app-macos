//
//  QuickActionsSection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import ComposableArchitecture
import SwiftUI

// MARK: - View

struct QuickActionsSection: View {
    @Environment(\.redactionReasons) private var redactionReasons

    typealias State = QuickActionsSectionState
    typealias Action = QuickActionsSectionAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    var body: some View {
        HStack(spacing: 24) {
            Button { actions.send(.startCallTapped) } label: {
                Label("phone", systemImage: "phone")
            }
            Button { actions.send(.composeEmailTapped) } label: {
                Label("email", systemImage: "envelope")
            }
        }
        .buttonStyle(SubtitledActionButtonStyle())
        .unredacted()
        .disabled(redactionReasons.contains(.placeholder))
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let quickActionsSectionReducer: Reducer<
    QuickActionsSectionState,
    QuickActionsSectionAction,
    Void
> = Reducer { _, action, _ in
    switch action {
    case .startCallTapped:
        // TODO: Handle action
        logger.info("Phone tapped")

    case .composeEmailTapped:
        // TODO: Handle action
        logger.info("Email tapped")
    }

    return .none
}

// MARK: State

public struct QuickActionsSectionState: Equatable {
    public init() {}
}

extension QuickActionsSectionState {
    static var placeholder: QuickActionsSectionState {
        QuickActionsSectionState()
    }
}

// MARK: Actions

public enum QuickActionsSectionAction: Equatable {
    case startCallTapped, composeEmailTapped
}

// MARK: - Previews

struct QuickActionsSection_Previews: PreviewProvider {
    static var previews: some View {
        QuickActionsSection(store: Store(
            initialState: QuickActionsSectionState(),
            reducer: quickActionsSectionReducer,
            environment: ()
        ))
    }
}
