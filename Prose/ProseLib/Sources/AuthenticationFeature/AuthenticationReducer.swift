//
//  AuthenticationReducer.swift
//  Prose
//
//  Created by Marc Bauer on 01/04/2022.
//

import AppKit
import Combine
import ComposableArchitecture
import Foundation
// import ProseCore
import SharedModels

// MARK: - The Composable Architecture

// MARK: State

public struct AuthenticationState: Equatable {
    @BindableState var jid: String
    @BindableState var password: String

    var isFormValid: Bool {
        !self.jid.isEmpty && !self.password.isEmpty
    }

    public init(
        jid: String = "",
        password: String = ""
    ) {
        self.jid = jid
        self.password = password
    }
}

// MARK: Actions

public enum AuthenticationAction: Equatable, BindableAction {
    case loginButtonTapped
//    case loginResult(Result<UserCredentials, EquatableError>)
    case loginResult(Result<String, AuthenticationError>)
    case binding(BindingAction<AuthenticationState>)
}

// MARK: Environment

public struct AuthenticationEnvironment: Equatable {
//    var login: (String, String, ClientOrigin) -> Effect<Result<UserCredentials, EquatableError>, Never>

    public init() {}

//    public init(login: @escaping (String, String, ClientOrigin)
//        -> Effect<Result<UserCredentials, EquatableError>, Never>)
//    {
//        self.login = login
//    }
}

// MARK: Reducer

public let authenticationReducer = Reducer<
    AuthenticationState,
    AuthenticationAction,
    AuthenticationEnvironment
> { state, action, _ in
    switch action {
    case .loginButtonTapped:
        print("Log in button tapped")
        if state.isFormValid {
            return Effect(value: .loginResult(.success(state.jid)))
        } else {
            return Effect(value: .loginResult(.failure(.badCredentials)))
        }
//        return environment.login(state.jid, state.password, .proseAppMacOs)
//            .map(AuthenticationAction.loginResult)

    case let .loginResult(.success(jid)):
        print("Login success: \(jid)")

    case let .loginResult(.failure(reason)):
        print("Login failure: \(reason)")

//    case let .loginResult(.success(credentials)):
//        return .none
//
//    case let .loginResult(.failure(error)):
//        state.alert = .init(title: .init(error.localizedDescription))
//        return .none

    case .binding:
        break
    }

    return .none
}.binding()
