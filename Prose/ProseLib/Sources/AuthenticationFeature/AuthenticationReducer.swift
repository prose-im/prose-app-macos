import ComposableArchitecture
import Foundation

public struct AuthenticationState: Equatable {
  @BindableState var email = "test@example.com"
  @BindableState var password = "topsecret"

  var isFormValid = true

  public init() {}
}

public enum AuthenticationAction: BindableAction, Equatable {
  case binding(BindingAction<AuthenticationState>)
  case loginButtonTapped
}

public struct AuthenticationEnvironment {
  public init() {}
}

public let authenticationReducer = Reducer<
  AuthenticationState,
  AuthenticationAction,
  AuthenticationEnvironment
> { state, action, _ in
  switch action {
  case .binding:
    state.isFormValid = !state.email.isEmpty && !state.password.isEmpty
    return .none

  case .loginButtonTapped:
    return .none
  }
}.binding()
