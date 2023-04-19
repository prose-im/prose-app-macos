//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppKit
import AppLocalization
import Combine
import ComposableArchitecture
import CredentialsClient
import Foundation
import ProseCore
import Toolbox

private let l10n = L10n.Authentication.BasicAuth.self

struct InvalidJIDError: Error {}

public struct BasicAuthReducer: ReducerProtocol {
  public struct State: Equatable {
    public enum Field: String, Hashable {
      case address, password
    }

    public enum Popover: String, Hashable {
      case chatAddress, noAccount, passwordLost
    }

    @BindingState var jid: String
    @BindingState var password: String
    @BindingState var focusedField: Field?
    @BindingState var popover: Popover?

    var isLoading: Bool
    var alert: AlertState<Action>?

    var isFormValid: Bool { self.isAddressValid && self.isPasswordValid }
    var isAddressValid: Bool { !self.jid.isEmpty }
    var isPasswordValid: Bool { !self.password.isEmpty }
    var isLogInButtonEnabled: Bool { self.isFormValid }
    /// The action button is shown either when the form is valid or when the login request is in
    /// flight
    /// (for cancellation).
    var isActionButtonEnabled: Bool { self.isLogInButtonEnabled || self.isLoading }

    public init(
      jid: String = "",
      password: String = "",
      focusedField: Field? = nil,
      popover: Popover? = nil,
      isLoading: Bool = false,
      alert: AlertState<Action>? = nil
    ) {
      self.jid = jid
      self.password = password
      self.focusedField = focusedField
      self.popover = popover
      self.isLoading = isLoading
      self.alert = alert
    }
  }

  public enum Action: Equatable, BindableAction {
    case alertDismissed
    case loginButtonTapped, showPopoverTapped(State.Popover)
    case submitTapped(State.Field), cancelLogInTapped
    case loginResult(TaskResult<BareJid>)
    case binding(BindingAction<State>)
  }

  @Dependency(\.accountBookmarksClient) var accountBookmarks
  @Dependency(\.credentialsClient) var credentials
  @Dependency(\.accountsClient) var accounts

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce<State, Action> { state, action in
      struct CancelId: Hashable {}

      func performLogin() -> EffectTask<Action> {
        guard state.isFormValid else {
          return .none
        }

        state.focusedField = nil
        state.isLoading = true

        return .task { [jidString = state.jid, password = state.password] in
          await .loginResult(TaskResult {
            guard let jid = BareJid(rawValue: jidString) else {
              throw InvalidJIDError()
            }

            let credentials = Credentials(jid: jid, password: password)

            try await self.accounts.tryConnectAccount(credentials)
            try? await self.accountBookmarks.addBookmark(jid)
            try? self.credentials.save(credentials)

            return jid
          })
        }
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
        return EffectTask.cancel(id: CancelId())

      case .loginResult(.success):
        state.isLoading = false
        return .none

      case let .loginResult(.failure(reason)):
        let errorMessage: String
        if case ConnectionError.InvalidCredentials = reason {
          errorMessage = "Invalid credentials"
        } else {
          errorMessage = reason.localizedDescription
        }

        logger.debug("Login failure: \(String(reflecting: reason))")
        state.isLoading = false

        state.alert = .init(
          title: TextState(l10n.Error.title),
          message: TextState(errorMessage)
        )
        return .none

      case .binding:
        break
      }

      return .none
    }
  }
}
