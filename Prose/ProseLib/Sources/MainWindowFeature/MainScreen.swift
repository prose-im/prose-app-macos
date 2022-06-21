//
//  MainScreen.swift
//  Prose
//
//  Created by Rémi Bardon on 01/06/2022.
//

import ComposableArchitecture
import ProseCoreStub
import SidebarFeature
import SwiftUI
import TcaHelpers

// MARK: - View

public struct MainScreen: View {
    public typealias State = MainScreenState
    public typealias Action = MainScreenAction

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
    MainScreenState,
    MainScreenAction,
    MainScreenEnvironment
> = sidebarReducer._pullback(
    state: \MainScreenState.sidebar,
    action: CasePath(MainScreenAction.sidebar),
    environment: \MainScreenEnvironment.sidebar
)

// MARK: State

public struct MainScreenState: Equatable {
    var sidebar: SidebarState

    public init(
        sidebar: SidebarState
    ) {
        self.sidebar = sidebar
    }
}

public extension MainScreenState {
    static var placeholder: MainScreenState {
        MainScreenState(
            sidebar: .placeholder
        )
    }
}

// MARK: Actions

public enum MainScreenAction: Equatable {
    case sidebar(SidebarAction)
}

// MARK: Environment

public struct MainScreenEnvironment {
    let userStore: UserStore
    let messageStore: MessageStore
    let statusStore: StatusStore
    let securityStore: SecurityStore
    
    var sidebar: SidebarEnvironment {
        SidebarEnvironment(
            userStore: self.userStore,
            messageStore: self.messageStore,
            statusStore: self.statusStore,
            securityStore:self.securityStore
        )
    }
    
    public init(
        userStore: UserStore,
        messageStore: MessageStore,
        statusStore: StatusStore,
        securityStore: SecurityStore
    ) {
        self.userStore = userStore
        self.messageStore = messageStore
        self.statusStore = statusStore
        self.securityStore = securityStore
    }
}

public extension MainScreenEnvironment {
    static var stub: MainScreenEnvironment {
        MainScreenEnvironment(
            userStore: .stub,
            messageStore: .stub,
            statusStore: .stub,
            securityStore: .stub
        )
    }
}

public extension MainScreenEnvironment {
    static var placeholder: MainScreenEnvironment {
        MainScreenEnvironment(
            userStore: .placeholder,
            messageStore: .placeholder,
            statusStore: .placeholder,
            securityStore: .placeholder
        )
    }
}

// MARK: - Previews

#if DEBUG
    import PreviewAssets

    internal struct MainWindow_Previews: PreviewProvider {
        static var previews: some View {
            MainScreen(store: Store(
                initialState: MainScreenState(
                    sidebar: .init(
                        credentials: UserCredentials(jid: "preview@prose.org"),
                        footer: FooterState(
                            avatar: .init(avatar: .init(url: PreviewAsset.Avatars.valerian.customURL))
                        )
                    )
                ),
                reducer: mainWindowReducer,
                environment: .stub
            ))
        }
    }
#endif
