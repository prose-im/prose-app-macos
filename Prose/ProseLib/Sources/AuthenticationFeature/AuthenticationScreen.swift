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
    public typealias State = AuthRoute
    public typealias Action = AuthenticationAction

    private let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    public init(store: Store<State, Action>) {
        self.store = store
    }

    public var body: some View {
        SwitchStore(self.store) {
            CaseLet(state: /State.logIn, action: Action.logIn, then: LogInView.init(store:))
            CaseLet(state: /State.mfa, action: Action.mfa, then: MFAView.init(store:))
        }
    }
}

// MARK: - The Composabe Architecture

// MARK: Reducer

public let authenticationReducer: Reducer<
    AuthRoute,
    AuthenticationAction,
    AuthenticationEnvironment
> = Reducer.combine([
    logInReducer.pullback(
        state: /AuthRoute.logIn,
        action: /AuthenticationAction.logIn,
        environment: { $0 }
    ),
    mfaReducer.pullback(
        state: /AuthRoute.mfa,
        action: /AuthenticationAction.mfa,
        environment: { $0 }
    ),
    Reducer { state, action, _ in
        switch action {
        case let .logIn(.didPassChallenge(.success(jid, token))),
             let .mfa(.didPassChallenge(.success(jid, token))):
            return Effect(value: .didLogIn(jid: jid, token: token))

        case let .logIn(.didPassChallenge(route)),
             let .mfa(.didPassChallenge(route)):
            state = route

        default:
            break
        }

        return .none
    },
])

// MARK: State

public enum AuthRoute: Equatable {
    case logIn(LogInState)
    case mfa(MFAState)
    case success(jid: String, token: String)
}

// MARK: Actions

public enum AuthenticationAction: Equatable {
    case didLogIn(jid: String, token: String)
    case logIn(LogInAction)
    case mfa(MFAAction)
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
