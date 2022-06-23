//
//  Toolbar.swift
//  Prose
//
//  Created by Rémi Bardon on 02/06/2022.
//

import ComposableArchitecture
import ProseUI
import SharedModels
import SwiftUI

// MARK: - View

struct Toolbar: ToolbarContent {
    typealias State = ToolbarState
    typealias Action = ToolbarAction

    @Environment(\.redactionReasons) private var redactionReasons

    let store: Store<State, Action>

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigation) {
            Self.navigationButtons(store: self.store)
        }

        ToolbarItemGroup {
            Self.otherButtons(
                store: self.store,
                redactionReasons: redactionReasons
            )
        }
    }

    @ViewBuilder
    static func navigationButtons(store: Store<State, Action>) -> some View {
        CommonToolbarNavigation()

        IfLetStore(store.scope(state: \State.user)) { store in
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

    @ViewBuilder
    static func otherButtons(
        store: Store<State, Action>,
        redactionReasons: RedactionReasons
    ) -> some View {
        IfLetStore(store.scope(state: \State.user)) { store in
            WithViewStore(store) { viewStore in
                ToolbarSecurity(
                    jid: viewStore.jid,
                    // TODO: Make this dynamic
                    isVerified: true
                )

                ToolbarDivider()
            }
        }

        Self.actionItems(store: store, redactionReasons: redactionReasons)

        ToolbarDivider()

        CommonToolbarActions()
    }

    static func actionItems(
        store: Store<State, Action>,
        redactionReasons: RedactionReasons
    ) -> some View {
        WithViewStore(store) { viewStore in
            Button { viewStore.send(.startVideoCallTapped) } label: {
                Label("Video", systemImage: "video")
            }

            Toggle(isOn: viewStore.binding(\State.$isShowingInfo).animation()) {
                Label("Info", systemImage: "info.circle")
            }
            .disabled(viewStore.user == nil)
        }
        .unredacted()
        .disabled(redactionReasons.contains(.placeholder))
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
        logger.info("Start video call tapped")

    case .binding(\ToolbarState.$isShowingInfo):
        if state.isShowingInfo {
            logger.info("Show info tapped")
        } else {
            logger.info("Stop showing info tapped")
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

// MARK: - Previews

internal struct Toolbar_Previews: PreviewProvider {
    private struct Preview: View {
        @Environment(\.redactionReasons) private var redactionReasons

        let state: ToolbarState

        var body: some View {
            let store = Store(
                initialState: state,
                reducer: toolbarReducer,
                environment: ()
            )
            VStack(alignment: .leading) {
                HStack {
                    Toolbar.navigationButtons(store: store)
                }
                HStack {
                    Toolbar.otherButtons(
                        store: store,
                        redactionReasons: redactionReasons
                    )
                }
            }
            .padding()
            .previewLayout(.sizeThatFits)
        }
    }

    static var previews: some View {
        Preview(state: .init(user: nil))
        Preview(state: .init(user: nil))
            .redacted(reason: .placeholder)
            .previewDisplayName("Placeholder")
    }
}
