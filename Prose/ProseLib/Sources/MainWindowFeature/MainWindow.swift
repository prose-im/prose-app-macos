//
//  MainWindow.swift
//  Prose
//
//  Created by Rémi Bardon on 01/06/2022.
//

import ComposableArchitecture
import SidebarFeature
import SwiftUI
import TcaHelpers

// MARK: - View

public struct MainWindow: View {
    public typealias State = MainWindowState
    public typealias Action = MainWindowAction

    private let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    // swiftlint:disable:next type_contents_order
    public init(store: Store<State, Action>) {
        self.store = store
    }

    public var body: some View {
        NavigationView {
            // NOTE: [Rémi Bardon] For some reason, using `\State.sidebar` causes
            //       `Key path value type 'SidebarState' cannot be converted to contextual type
            //       'SidebarView.State' (aka 'SidebarState')`. We need to omit `State`.
            SidebarView(store: self.store.scope(state: \.sidebar, action: Action.sidebar))
            Text("Nothing to show here 🤷")
        }
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let mainWindowReducer: Reducer<
    MainWindowState,
    MainWindowAction,
    MainWindowEnvironment
> = sidebarReducer._pullback(
    state: \MainWindowState.sidebar,
    action: /MainWindowAction.sidebar,
    environment: \MainWindowEnvironment.sidebar
)

// MARK: State

public struct MainWindowState: Equatable {
    var sidebar: SidebarState

    public init(
        sidebar: SidebarState
    ) {
        self.sidebar = sidebar
    }
}

// MARK: Actions

public enum MainWindowAction: Equatable {
    case sidebar(SidebarAction)
}

// MARK: Environment

public struct MainWindowEnvironment {
    var sidebar: SidebarEnvironment

    public init(
        sidebar: SidebarEnvironment
    ) {
        self.sidebar = sidebar
    }
}

// MARK: - Previews

internal struct MainWindow_Previews: PreviewProvider {
    static var previews: some View {
        MainWindow(store: Store(
            initialState: MainWindowState(
                sidebar: .init(credentials: UserCredentials(jid: "preview@prose.org"))
            ),
            reducer: mainWindowReducer,
            environment: MainWindowEnvironment(
                sidebar: .stub
            )
        ))
    }
}
