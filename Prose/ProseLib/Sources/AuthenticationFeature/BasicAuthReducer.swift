//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppKit
import AppLocalization
import Combine
import ComposableArchitecture
import Foundation
import ProseCoreTCA
import Toolbox

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
  case loginResult(Result<AuthRoute, EquatableError>)
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

  func performLogin() -> Effect<BasicAuthAction, Never> {
    guard state.isFormValid else {
      return .none
    }

    state.focusedField = nil
    state.isLoading = true

    let jid: JID
    do {
      jid = try JID(string: state.jid)
    } catch {
      return Effect(value: .loginResult(.failure(EquatableError(error))))
    }
    let password = state.password

    return environment.proseClient.login(jid, password)
      .map { _ in AuthRoute.success(jid: jid, password: password) }
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(BasicAuthAction.loginResult)
      .cancellable(id: CancelId())
  }

  switch action {
  case .alertDismissed:
    state.alert = nil

  case .loginButtonTapped:
    return performLogin()

  case let .showPopoverTapped(popover):
    state.focusedField = nil
    state.popover = popover

  case .submitTapped(.address):
    state.focusedField = .password

  case .submitTapped(.password):
    return performLogin()

  case .cancelLogInTapped:
    state.isLoading = false
    return Effect.cancel(id: CancelId())

  case let .loginResult(.success(route)):
    state.isLoading = false
    return Effect(value: .didPassChallenge(next: route))

  case let .loginResult(.failure(reason)):
    logger.debug("Login failure: \(String(reflecting: reason))")
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
