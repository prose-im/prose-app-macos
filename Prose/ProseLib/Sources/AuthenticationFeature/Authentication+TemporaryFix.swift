//
//  Authentication+TemporaryFix.swift
//  Prose
//
//  Created by Rémi Bardon on 02/06/2022.
//

import ComposableArchitecture
import SwiftUI

// swiftlint:disable file_types_order

// MARK: - View

public struct AuthenticationView: View {
    public typealias State = AuthenticationState
    public typealias Action = AuthenticationAction

    private let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    // swiftlint:disable:next type_contents_order
    public init(store: Store<State, Action>) {
        self.store = store
    }

    public var body: some View {
        Text("Implement me")
    }
}

// MARK: - The Composabe Architecture

// MARK: Reducer

public let authenticationReducer: Reducer<
    AuthenticationState,
    AuthenticationAction,
    AuthenticationEnvironment
> = Reducer.empty

// MARK: State

public struct AuthenticationState: Equatable {
    public init() {}
}

// MARK: Actions

public enum AuthenticationAction: Equatable {}

// MARK: Environment

public struct AuthenticationEnvironment: Equatable {
    public init() {}
}
