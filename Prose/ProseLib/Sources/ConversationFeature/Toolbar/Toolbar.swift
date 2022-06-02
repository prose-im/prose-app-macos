//
//  Toolbar.swift
//  Prose
//
//  Created by Rémi Bardon on 02/06/2022.
//

import ComposableArchitecture
import ProseUI
import SwiftUI

// MARK: - View

struct Toolbar: ToolbarContent {
    typealias State = ToolbarState
    typealias Action = ToolbarAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigation) {
            CommonToolbarNavigation()

            IfLetStore(self.store.scope(state: \State.user)) { store in
                ToolbarDivider()

                WithViewStore(store) { viewStore in
                    ToolbarTitle(
                        name: viewStore.fullName,
                        // TODO: Make this dynamic
                        status: .online
                    )
                }
            }
        }

        ToolbarItemGroup {
            IfLetStore(self.store.scope(state: \State.user)) { store in
                WithViewStore(store) { viewStore in
                    ToolbarSecurity(
                        jid: viewStore.userId,
                        // TODO: Make this dynamic
                        isVerified: true
                    )

                    ToolbarDivider()
                }
            }

            actionItems()

            ToolbarDivider()

            CommonToolbarActions()
        }
    }

    @ViewBuilder
    private func actionItems() -> some View {
        Button { actions.send(.startVideoCallTapped) } label: {
            Label("Video", systemImage: "video")
        }

        WithViewStore(self.store) { viewStore in
            Toggle(isOn: viewStore.binding(\State.$isShowingInfo).animation()) {
                Label("Info", systemImage: "info.circle")
            }
            .disabled(viewStore.user == nil)
        }
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let toolbarReducer: Reducer<
    ToolbarState,
    ToolbarAction,
    Void
> = Reducer { state, action, _ in
    switch action {
    case .startVideoCallTapped:
        print("Start video call tapped")

    case .binding(\ToolbarState.$isShowingInfo):
        if state.isShowingInfo {
            print("Show info tapped")
        } else {
            print("Stop showing info tapped")
        }

    case .binding:
        break
    }

    return .none
}.binding()

// MARK: State

public struct ToolbarState: Equatable {
    let user: User?
    @BindableState var isShowingInfo: Bool

    public init(
        user: User?,
        showingInfo: Bool = false
    ) {
        self.user = user
        self.isShowingInfo = showingInfo
    }
}

// MARK: Actions

public enum ToolbarAction: Equatable, BindableAction {
    case startVideoCallTapped
    case binding(BindingAction<ToolbarState>)
}
