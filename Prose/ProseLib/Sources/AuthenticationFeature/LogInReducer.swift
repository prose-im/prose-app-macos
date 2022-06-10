//
//  LogInReducer.swift
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

public struct LogInState: Equatable {
    public enum Field: String, Hashable {
        case address, password
    }

    public enum Popover: String, Hashable {
        case chatAddress, noAccount, passwordLost
    }

    @BindableState var jid: String
    @BindableState var password: String
    @BindableState var focusedField: Field?
    @BindableState var popover: Popover?

    var isLoading: Bool
    var alert: AlertState<LogInAction>?

    var isFormValid: Bool { self.isAddressValid && self.isPasswordValid }
    var isAddressValid: Bool { !self.jid.isEmpty }
    var isPasswordValid: Bool { !self.password.isEmpty }
    var isLogInButtonEnabled: Bool { self.isFormValid }
    /// The action button is shown either when the form is valid or when the login request is in flight
    /// (for cancellation).
    var isActionButtonEnabled: Bool { self.isLogInButtonEnabled || self.isLoading }

    public init(
        jid: String = "",
        password: String = "",
        focusedField: Field? = nil,
        popover: Popover? = nil,
        isLoading: Bool = false,
        alert: AlertState<LogInAction>? = nil
    ) {
        self.jid = jid
        self.password = password
        self.focusedField = focusedField
        self.popover = popover
        self.isLoading = isLoading
        self.alert = alert
    }
}

// MARK: Actions

public enum LogInAction: Equatable, BindableAction {
    case alertDismissed
    case loginButtonTapped, showPopoverTapped(LogInState.Popover)
    case submitTapped(LogInState.Field), cancelLogInTapped
    case logIn
//    case loginResult(Result<UserCredentials, EquatableError>)
    case loginResult(Result<String, LogInError>)
    case binding(BindingAction<LogInState>)
}

// MARK: Reducer

public let logInReducer = Reducer<
    LogInState,
    LogInAction,
    AuthenticationEnvironment
> { state, action, environment in
    struct CancelId: Hashable {}

    switch action {
    case .alertDismissed:
        state.alert = nil

    case .loginButtonTapped:
        return Effect(value: .logIn)

    case .logIn:
        state.focusedField = nil
        state.isLoading = true

        let isFormValid = state.isFormValid
        let jid = state.jid
        return Effect.task {
            if isFormValid, !jid.starts(with: "error") {
                return .loginResult(.success(jid))
            } else {
                return .loginResult(.failure(.badCredentials))
            }
        }
        .delay(for: .seconds(1), scheduler: environment.mainQueue)
        .eraseToEffect()
        .cancellable(id: CancelId())
//        return environment.login(state.jid, state.password, .proseAppMacOs)
//            .map(LogInAction.loginResult)

    case let .showPopoverTapped(popover):
        state.focusedField = nil
        state.popover = popover

    case .submitTapped(.address):
        state.focusedField = .password

    case .submitTapped(.password):
        if state.isLogInButtonEnabled {
            return Effect(value: .logIn)
        }

    case .cancelLogInTapped:
        state.isLoading = false
        return Effect.cancel(id: CancelId())

    case let .loginResult(.success(jid)):
//    case let .loginResult(.success(credentials)):
        print("Login success: \(jid)")
        state.isLoading = false

    case let .loginResult(.failure(reason)):
        print("Login failure: \(String(reflecting: reason))")
        state.isLoading = false

        state.alert = .init(
            title: TextState("Login failure"),
            message: TextState(reason.localizedDescription)
        )

    case .binding:
        break
    }

    return .none
}.binding()
