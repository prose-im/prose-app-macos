//
//  SidebarView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/15/21.
//

import ComposableArchitecture
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
        SidebarContentView(store: self.store.scope(state: \State.content, action: Action.content))
            .frame(minWidth: 280)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Footer(store: self.store.scope(state: { ($0.footer, $0.credentials) }, action: Action.footer))
                    // Make sure accessibility frame isn't inset by the window's rounded corners
                    .contentShape(Rectangle())
                    // Make footer have a higher priority, to be accessible over the scroll view
                    .accessibilitySortPriority(1)
            }
            .toolbar {
                Toolbar(store: self.store.scope(state: \State.toolbar, action: Action.toolbar))
            }
    }
}

// MARK: - The Composabe Architecture

// MARK: Reducer

public let sidebarReducer: Reducer<
    SidebarState,
    SidebarAction,
    SidebarEnvironment
> = Reducer.combine([
    sidebarContentReducer.pullback(
        state: \SidebarState.content,
        action: /SidebarAction.content,
        environment: { _ in () }
    ),
    footerReducer.pullback(
        state: \SidebarState.footer,
        action: /SidebarAction.footer,
        environment: { _ in () }
    ),
    toolbarReducer.pullback(
        state: \SidebarState.toolbar,
        action: /SidebarAction.toolbar,
        environment: { $0 }
    ),
])

// MARK: State

public struct SidebarState: Equatable {
    public var credentials: UserCredentials
    public var content: SidebarContentState
    public var footer: FooterState
    public var toolbar: ToolbarState

    public init(
        credentials: UserCredentials,
        content: SidebarContentState = .init(),
        footer: FooterState = .init(),
        toolbar: ToolbarState = .init()
    ) {
        self.credentials = credentials
        self.content = content
        self.footer = footer
        self.toolbar = toolbar
    }

    public init(
        credentials: UserCredentials,
        route: Route,
        footer: FooterState = .init(),
        toolbar: ToolbarState = .init()
    ) {
        self.credentials = credentials
        self.content = .init(route: route)
        self.footer = footer
        self.toolbar = toolbar
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

public struct SidebarEnvironment: Equatable {
    public init() {}
}
