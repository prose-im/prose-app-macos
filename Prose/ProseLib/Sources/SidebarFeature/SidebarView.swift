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

    let store: Store<State, Action>

    public init(store: Store<State, Action>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            Content(store: self.store.scope(state: \State.content, action: Action.content))
            Footer(store: self.store.scope(state: { ($0.footer, $0.credentials) }, action: Action.footer))
        }
        .toolbar {
            Toolbar(store: self.store.scope(state: \State.toolbar, action: Action.toolbar))
        }
    }
}

// MARK: - The Composabe Architecture

// MARK: Reducer

private let sidebarCoreReducer = Reducer<
    SidebarState,
    SidebarAction,
    SidebarEnvironment
> { _, action, _ in
    switch action {
    case .content, .footer, .toolbar, .binding:
        break
    }

    return .none
}

public let sidebarReducer: Reducer<
    SidebarState,
    SidebarAction,
    SidebarEnvironment
> = Reducer.combine([
    contentReducer.pullback(
        state: \SidebarState.content,
        action: /SidebarAction.content,
        environment: { $0 }
    ),
    footerReducer.pullback(
        state: \SidebarState.footer,
        action: /SidebarAction.footer,
        environment: { $0 }
    ),
    toolbarReducer.pullback(
        state: \SidebarState.toolbar,
        action: /SidebarAction.toolbar,
        environment: { $0 }
    ),
    sidebarCoreReducer,
])

// MARK: State

public struct SidebarState: Equatable {
    public var credentials: UserCredentials
    public var content: ContentState
    public var footer: FooterState
    public var toolbar: ToolbarState

    public init(
        credentials: UserCredentials,
        content: ContentState = .init(),
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

public enum SidebarAction: BindableAction {
    case content(ContentAction)
    case footer(FooterAction)
    case toolbar(ToolbarAction)
    case binding(BindingAction<SidebarState>)
}

// MARK: Environment

public typealias SidebarEnvironment = Void
