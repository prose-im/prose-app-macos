import Combine
import ComposableArchitecture
import Foundation
// import ProseCore
import SharedModels

public struct AuthenticationState: Equatable {
    @BindableState var jid = "hello@prose.org"
    @BindableState var password = "password"

    var alert: AlertState<AuthenticationAction>?
    var isFormValid = true

    public init() {}
}

public enum AuthenticationAction: BindableAction, Equatable {
    case binding(BindingAction<AuthenticationState>)
    case alertDismissed
    case loginButtonTapped
    case loginResult(Result<UserCredentials, EquatableError>)
}

public struct AuthenticationEnvironment {
    var login: (String, String, ClientOrigin) -> Effect<Result<UserCredentials, EquatableError>, Never>

    public init(login: @escaping (String, String, ClientOrigin)
        -> Effect<Result<UserCredentials, EquatableError>, Never>)
    {
        self.login = login
    }
}

public let authenticationReducer = Reducer<
    AuthenticationState,
    AuthenticationAction,
    AuthenticationEnvironment
> { state, action, environment in
    switch action {
    case .binding:
        state.isFormValid = !state.jid.isEmpty && !state.password.isEmpty
        return .none

    case .alertDismissed:
        state.alert = nil
        return .none

    case .loginButtonTapped:
        return environment.login(state.jid, state.password, .proseAppMacOs)
            .map(AuthenticationAction.loginResult)

    case let .loginResult(.success(credentials)):
        return .none

    case let .loginResult(.failure(error)):
        state.alert = .init(title: .init(error.localizedDescription))
        return .none
    }
}.binding()
