//
//  Toolbar.swift
//  Prose
//
//  Created by Valerian Saliou on 12/12/21.
//

import AppLocalization
import ComposableArchitecture
import SwiftUI

// swiftlint:disable file_types_order

private let l10n = L10n.Sidebar.Toolbar.self

// MARK: - View

struct Toolbar: ToolbarContent {
    typealias State = ToolbarState
    typealias Action = ToolbarAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button { actions.send(.startCallTapped) } label: {
                Label(l10n.Actions.StartCall.label, systemImage: "phone.bubble.left")
            }
            .accessibilityHint(l10n.Actions.StartCall.hint)
            Button { actions.send(.writeMessageTapped) } label: {
                Label(l10n.Actions.WriteMessage.label, systemImage: "square.and.pencil")
            }
            .accessibilityHint(l10n.Actions.WriteMessage.hint)
        }
    }
}

// MARK: - The Composabe Architecture

// MARK: Reducer

private let toolbarCoreReducer: Reducer<
    ToolbarState,
    ToolbarAction,
    Void
> = Reducer { _, action, _ in
    switch action {
    case .startCallTapped:
        // TODO: [Rémi Bardon] Handle action
        print("Start call tapped")

    case .writeMessageTapped:
        // TODO: [Rémi Bardon] Handle action
        print("Write message tapped")
    }

    return .none
}

public let toolbarReducer: Reducer<
    ToolbarState,
    ToolbarAction,
    Void
> = Reducer.combine([
    toolbarCoreReducer,
])

// MARK: State

public struct ToolbarState: Equatable {
    public init() {}
}

// MARK: Actions

public enum ToolbarAction: Equatable {
    case startCallTapped, writeMessageTapped
}
