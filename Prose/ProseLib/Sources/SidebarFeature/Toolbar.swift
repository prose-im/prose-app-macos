//
//  Toolbar.swift
//  Prose
//
//  Created by Valerian Saliou on 12/12/21.
//

import AppLocalization
import ComposableArchitecture
import SwiftUI

private let l10n = L10n.Sidebar.Toolbar.self

// MARK: - View

struct Toolbar: ToolbarContent {
    typealias State = ToolbarState
    typealias Action = ToolbarAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: ToolbarItemPlacement.primaryAction) {
            Button { actions.send(.startCallTapped) } label: {
                Label(l10n.Actions.StartCall.label, systemImage: "phone.bubble.left")
            }
            .accessibilityHint(l10n.Actions.StartCall.hint)
            WithViewStore(self.store) { viewStore in
                Toggle(isOn: viewStore.binding(\State.$writingNewMessage)) {
                    Label(l10n.Actions.WriteMessage.label, systemImage: "square.and.pencil")
                }
                .toggleStyle(.button)
                .accessibilityHint(l10n.Actions.WriteMessage.hint)
            }
        }
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let toolbarReducer: Reducer<
    ToolbarState,
    ToolbarAction,
    SidebarEnvironment
> = Reducer { state, action, _ in
    switch action {
    case .startCallTapped:
        // TODO: [Rémi Bardon] Handle action
        print("Start call tapped")

    case .binding(\.$writingNewMessage):
        // TODO: [Rémi Bardon] Handle action
        if state.writingNewMessage {
            print("Start writing new message tapped")
        } else {
            print("Stop writing new message tapped")
        }

    case .binding:
        break
    }

    return .none
}.binding()

// MARK: State

public struct ToolbarState: Equatable {
    @BindableState public var writingNewMessage: Bool

    public init(
        writingNewMessage: Bool = false
    ) {
        self.writingNewMessage = writingNewMessage
    }
}

// MARK: Actions

public enum ToolbarAction: Equatable, BindableAction {
    case startCallTapped
    case binding(BindingAction<ToolbarState>)
}
