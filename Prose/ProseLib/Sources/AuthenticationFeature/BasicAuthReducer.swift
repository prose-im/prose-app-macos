//
//  BasicAuthReducer.swift
//  Prose
//
//  Created by Marc Bauer on 01/04/2022.
//

import AppKit
import AppLocalization
import Combine
import ComposableArchitecture
import Foundation
// import ProseCore
import SharedModels

private let l10n = L10n.Authentication.BasicAuth.self

// MARK: - The Composable Architecture

// MARK: State

public struct BasicAuthState: Equatable {
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
    var alert: AlertState<BasicAuthAction>?

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
        alert: AlertState<BasicAuthAction>? = nil
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

public enum BasicAuthAction: Equatable, BindableAction {
    case alertDismissed
    case loginButtonTapped, showPopoverTapped(BasicAuthState.Popover)
    case submitTapped(BasicAuthState.Field), cancelLogInTapped
    case logIn
//    case loginResult(Result<UserCredentials, EquatableError>)
    case loginResult(Result<AuthRoute, BasicAuthError>)
    case didPassChallenge(next: AuthRoute)
    case binding(BindingAction<BasicAuthState>)
}

// MARK: Reducer

public let basicAuthReducer = Reducer<
    BasicAuthState,
    BasicAuthAction,
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
        let jid = JID(rawValue: state.jid)
        let password = state.password
        return Effect.task {
            if isFormValid, jid.node != "error" {
                if jid.node == "mfa" {
                    return .loginResult(.success(.mfa(.sixDigits(MFA6DigitsState(
                        jid: jid,
                        password: password
                    )))))
                } else {
                    return .loginResult(.success(.success(jid: jid, password: password)))
                }
            } else {
                return .loginResult(.failure(.badCredentials))
            }
        }
        .delay(for: .seconds(1), scheduler: environment.mainQueue)
        .eraseToEffect()
        .cancellable(id: CancelId())
//        return environment.login(state.jid, state.password, .proseAppMacOs)
//            .map(BasicAuthAction.loginResult)

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

    case let .loginResult(.success(route)):
//    case let .loginResult(.success(credentials)):
        state.isLoading = false

        return Effect(value: .didPassChallenge(next: route))

    case let .loginResult(.failure(reason)):
        print("Login failure: \(String(reflecting: reason))")
        state.isLoading = false

        state.alert = .init(
            title: TextState(l10n.Error.title),
            message: TextState(reason.localizedDescription)
        )

    case .didPassChallenge, .binding:
        break
    }

    return .none
}.binding()
