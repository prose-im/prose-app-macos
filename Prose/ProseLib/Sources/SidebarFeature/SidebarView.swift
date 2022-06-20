//
//  SidebarView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/15/21.
//

import ComposableArchitecture
import ProseCoreStub
import SwiftUI

// MARK: - View

/// The sidebar on the left of the screen.
public struct SidebarView: View {
    public typealias State = SidebarState
    public typealias Action = SidebarAction

    private let store: Store<State, Action>

    public init(store: Store<State, Action>) {
        self.store = store
    }

    public var body: some View {
        SidebarContentView(store: self.store.scope(state: \.content, action: Action.content))
            .frame(minWidth: 280)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Footer(store: self.store.scope(state: \.footerView, action: Action.footer))
                    // Make sure accessibility frame isn't inset by the window's rounded corners
                    .contentShape(Rectangle())
                    // Make footer have a higher priority, to be accessible over the scroll view
                    .accessibilitySortPriority(1)
            }
            .toolbar {
                Toolbar(store: self.store.scope(state: \.toolbar, action: Action.toolbar))
            }
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let sidebarReducer: Reducer<
    SidebarState,
    SidebarAction,
    SidebarEnvironment
> = Reducer.combine([
    sidebarContentReducer.pullback(
        state: \SidebarState.content,
        action: CasePath(SidebarAction.content),
        environment: { $0 }
    ),
    footerReducer.pullback(
        state: \SidebarState.footerView,
        action: CasePath(SidebarAction.footer),
        environment: { _ in () }
    ),
    toolbarReducer.pullback(
        state: \SidebarState.toolbar,
        action: CasePath(SidebarAction.toolbar),
        environment: { $0 }
    ),
])

// MARK: State

public struct SidebarState: Equatable {
    var credentials: UserCredentials
    var content: SidebarContentState
    var footer: FooterState
    var toolbar: ToolbarState

    var footerView: (FooterState, UserCredentials) {
        get { (self.footer, self.credentials) }
        set {
            self.footer = newValue.0
            self.credentials = newValue.1
        }
    }

    public init(
        credentials: UserCredentials,
        content: SidebarContentState = .init(),
        footer: FooterState,
        toolbar: ToolbarState = .init()
    ) {
        self.credentials = credentials
        self.content = content
        self.footer = footer
        self.toolbar = toolbar
    }
}

public extension SidebarState {
    static var placeholder: SidebarState {
        SidebarState(
            credentials: UserCredentials(
                jid: "valerian@prose.org"
            ),
            content: .placeholder,
            footer: FooterState(
                teamName: "Prose",
                statusIcon: "🚀",
                statusMessage: "Shipping new features",
                avatar: FooterAvatarState(
                    avatar: "avatars/valerian",
                    availability: .available,
                    fullName: "Valerian Saliou",
                    jid: "valerian@prose.org",
                    statusIcon: "🚀",
                    statusMessage: "Shipping new features"
                ),
                actionButton: FooterActionMenuState()
            ),
            toolbar: ToolbarState()
        )
    }
}

// MARK: Actions

public enum SidebarAction: Equatable, BindableAction {
    case content(SidebarContentAction)
    case footer(FooterAction)
    case toolbar(ToolbarAction)
    case binding(BindingAction<SidebarState>)
}

// MARK: Environment

public struct SidebarEnvironment {
    let userStore: UserStore
    let messageStore: MessageStore
    let statusStore: StatusStore
    let securityStore: SecurityStore

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

public extension SidebarEnvironment {
    static var placeholder: SidebarEnvironment {
        SidebarEnvironment(
            userStore: .placeholder,
            messageStore: .placeholder,
            statusStore: .placeholder,
            securityStore: .placeholder
        )
    }
}

public extension SidebarEnvironment {
    static var stub: SidebarEnvironment {
        SidebarEnvironment(
            userStore: .stub,
            messageStore: .stub,
            statusStore: .stub,
            securityStore: .stub
        )
    }
}

public extension SidebarEnvironment {
    var destination: NavigationDestinationEnvironment {
        NavigationDestinationEnvironment(
            userStore: self.userStore,
            messageStore: self.messageStore,
            statusStore: self.statusStore,
            securityStore: self.securityStore
        )
    }
}
