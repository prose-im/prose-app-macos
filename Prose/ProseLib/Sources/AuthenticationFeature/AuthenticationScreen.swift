//
//  AuthenticationScreen.swift
//  Prose
//
//  Created by Rémi Bardon on 10/06/2022.
//

import ComposableArchitecture
import SharedModels
import SwiftUI

// MARK: - View

public struct AuthenticationScreen: View {
    public typealias State = AuthenticationState
    public typealias Action = AuthenticationAction

    private let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    public init(store: Store<State, Action>) {
        self.store = store
    }

    public var body: some View {
        SwitchStore(self.store) {
            CaseLet(state: /State.logIn, action: Action.logIn, then: LogInView.init(store:))
        }
    }
}

// MARK: - The Composabe Architecture

// MARK: Reducer

public let authenticationReducer: Reducer<
    AuthenticationState,
    AuthenticationAction,
    AuthenticationEnvironment
> = Reducer.combine([
    logInReducer.pullback(
        state: /AuthenticationState.logIn,
        action: /AuthenticationAction.logIn,
        environment: { $0 }
    ),
    Reducer { _, action, _ in
        switch action {
        case let .logIn(.loginResult(.success(jid))):
            return Effect(value: .didLogIn(jid))

        default:
            break
        }

        return .none
    },
])

// MARK: State

public enum AuthenticationState: Equatable {
    case logIn(LogInState)
}

// MARK: Actions

public enum AuthenticationAction: Equatable {
    case didLogIn(String)
    case logIn(LogInAction)
}

// MARK: Environment

public struct AuthenticationEnvironment {
//    var login: (String, String, ClientOrigin) -> Effect<Result<UserCredentials, EquatableError>, Never>
    var mainQueue: AnySchedulerOf<DispatchQueue>

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.mainQueue = mainQueue
    }


//    public init(login: @escaping (String, String, ClientOrigin)
//        -> Effect<Result<UserCredentials, EquatableError>, Never>)
//    {
//        self.login = login
//    }
}

// MARK: - Previews

internal struct AuthenticationScreen_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationScreen(store: Store(
            initialState: .logIn(.init()),
            reducer: authenticationReducer,
            environment: AuthenticationEnvironment(
                mainQueue: .main
            )
        ))
    }
}
