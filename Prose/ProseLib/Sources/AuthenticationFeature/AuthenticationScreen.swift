//
//  AuthenticationScreen.swift
//  Prose
//
//  Created by Rémi Bardon on 10/06/2022.
//

import ComposableArchitecture
import CredentialsClient
import SharedModels
import SwiftUI
import TcaHelpers

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
        SwitchStore(self.store.scope(state: \State.route)) {
            CaseLet(state: /AuthRoute.basicAuth, action: Action.basicAuth, then: BasicAuthView.init(store:))
            CaseLet(state: /AuthRoute.mfa, action: Action.mfa, then: MFAView.init(store:))
        }
        .frame(minWidth: 400)
    }
}

// MARK: - The Composabe Architecture

// MARK: Reducer

public let authenticationReducer: Reducer<
    AuthenticationState,
    AuthenticationAction,
    AuthenticationEnvironment
> = Reducer.combine([
    basicAuthReducer._pullback(
        state: (\AuthenticationState.route).case(/AuthRoute.basicAuth),
        action: /AuthenticationAction.basicAuth,
        environment: { $0 }
    ),
    mfaReducer._pullback(
        state: (\AuthenticationState.route).case(/AuthRoute.mfa),
        action: /AuthenticationAction.mfa,
        environment: { $0 }
    ),
    Reducer { state, action, _ in
        switch action {
        case let .basicAuth(.didPassChallenge(.success(jid, password))),
             let .mfa(.didPassChallenge(.success(jid, password))):
            return Effect(value: .didLogIn(jid: jid, password: password))

        case let .basicAuth(.didPassChallenge(route)),
             let .mfa(.didPassChallenge(route)):
            state.route = route

        default:
            break
        }

        return .none
    },
])

// MARK: State

public struct AuthenticationState: Equatable {
    var route: AuthRoute

    public init(
        route: AuthRoute
    ) {
        self.route = route
    }
}

public enum AuthRoute: Equatable {
    case basicAuth(BasicAuthState)
    case mfa(MFAState)
    case success(jid: JID, password: String)
}

// MARK: Actions

public enum AuthenticationAction: Equatable {
    case didLogIn(jid: JID, password: String)
    case basicAuth(BasicAuthAction)
    case mfa(MFAAction)
}

// MARK: Environment

public struct AuthenticationEnvironment {
    var credentials: CredentialsClient

//    var login: (String, String, ClientOrigin) -> Effect<Result<UserCredentials, EquatableError>, Never>
    var mainQueue: AnySchedulerOf<DispatchQueue>

    public init(
        credentials: CredentialsClient,
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.credentials = credentials
        self.mainQueue = mainQueue
    }

//    public init(login: @escaping (String, String, ClientOrigin)
//        -> Effect<Result<UserCredentials, EquatableError>, Never>)
//    {
//        self.login = login
//    }
}

public extension AuthenticationEnvironment {
    static var placeholder: AuthenticationEnvironment {
        AuthenticationEnvironment(
            credentials: .placeholder,
            mainQueue: .main
        )
    }
}

// MARK: - Previews

internal struct AuthenticationScreen_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationScreen(store: Store(
            initialState: AuthenticationState(route: .basicAuth(.init())),
            reducer: authenticationReducer,
            environment: AuthenticationEnvironment(
                credentials: .live(service: "org.prose.Prose.preview.\(Self.self)"),
                mainQueue: .main
            )
        ))
    }
}
