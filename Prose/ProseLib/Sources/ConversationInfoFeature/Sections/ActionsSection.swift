//
//  ActionsSection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import AppLocalization
import ComposableArchitecture
import SwiftUI

private let l10n = L10n.Content.MessageDetails.Actions.self

// MARK: - View

struct ActionsSection: View {
    typealias State = ActionsSectionState
    typealias Action = ActionsSectionAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    var body: some View {
        GroupBox(l10n.title) {
            ActionRow(
                name: l10n.sharedFiles,
                deployTo: true,
                action: { actions.send(.viewSharedFilesTapped) }
            )
            ActionRow(
                name: l10n.encryptionSettings,
                deployTo: true,
                action: { actions.send(.encryptionSettingsTapped) }
            )
            // TODO: [Rémi Bardon] We should make this red, as it's a destructive action (using the `role` parameter of `Button`)
            ActionRow(
                name: l10n.removeContact,
                action: { actions.send(.removeContactTapped) }
            )
            // TODO: [Rémi Bardon] We should make this red, as it's a destructive action (using the `role` parameter of `Button`)
            ActionRow(
                name: l10n.block,
                action: { actions.send(.blockContactTapped) }
            )
        }
        .unredacted()
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let actionsSectionReducer: Reducer<
    ActionsSectionState,
    ActionsSectionAction,
    Void
> = Reducer { _, action, _ in
    switch action {
    case .viewSharedFilesTapped:
        print("View shared files tapped")

    case .encryptionSettingsTapped:
        print("Encryption settings tapped")

    case .removeContactTapped:
        print("Remove contact tapped")

    case .blockContactTapped:
        print("Block tapped")
    }

    return .none
}

// MARK: State

public struct ActionsSectionState: Equatable {
    public init() {}
}

extension ActionsSectionState {
    static var placeholder: Self {
        Self()
    }
}

// MARK: Actions

public enum ActionsSectionAction: Equatable {
    case viewSharedFilesTapped
    case encryptionSettingsTapped
    case removeContactTapped
    case blockContactTapped
}

// MARK: Environment

public struct ActionsSectionEnvironment: Equatable {
    public init() {}
}

// MARK: - Previews

struct ActionsSection_Previews: PreviewProvider {
    static var previews: some View {
        ActionsSection(store: Store(
            initialState: ActionsSectionState(),
            reducer: actionsSectionReducer,
            environment: ()
        ))
    }
}
