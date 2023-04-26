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

struct InvalidJIDError: Error {}

public struct BasicAuthReducer: ReducerProtocol {
  public struct State: Equatable {
    public enum Field: String, Hashable {
      case address, password
    }

    public enum Popover: String, Hashable {
      case chatAddress, noAccount, passwordLost
    }

    @BindingState var jid = ""
    @BindingState var password = ""
    @BindingState var focusedField: Field?
    @BindingState var popover: Popover?

    var isLoading = false
    var alert: AlertState<Action>?

    var isFormValid: Bool {
      !self.jid.isEmpty && !self.password.isEmpty
    }

    var isSubmitButtonEnabled: Bool {
      self.isLoading || self.isFormValid
    }

    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case submitButtonTapped
    case alertDismissed
    case showPopoverTapped(State.Popover)
    case fieldSubmitted(State.Field)
    case loginResult(TaskResult<UserData>)
    case binding(BindingAction<State>)
  }

  private enum EffectToken: Hashable, CaseIterable {
    case login
  }

  @Dependency(\.accountsClient) var accounts

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce<State, Action> { state, action in
      func performLogin() -> EffectTask<Action> {
        guard state.isFormValid else {
          return .none
        }

        state.focusedField = nil
        state.isLoading = true

        return .task { [jidString = state.jid, password = state.password] in
          await withTaskCancellation(id: EffectToken.login) {
            await .loginResult(
              TaskResult {
                guard let jid = BareJid(rawValue: jidString) else {
                  throw InvalidJIDError()
                }

                do {
                  let credentials = Credentials(jid: jid, password: password)

                  try self.accounts.addEphemeralAccount(jid)
                  let client = try self.accounts.ephemeralClient(jid)

                  try await client.connect(credentials, .available, nil, false)
                  let profile = try await client.loadProfile(jid, .reloadIgnoringCacheData)
                  let avatar = try await client.loadAvatar(jid, .reloadIgnoringCacheData)

                  if Task.isCancelled {
                    throw CancellationError()
                  }

                  return UserData(
                    credentials: credentials,
                    avatar: avatar,
                    profile: profile
                  )
                } catch {
                  self.accounts.removeEphemeralAccount(jid)
                  throw error
                }
              }
            )
          }
        }.cancellable(id: EffectToken.login)
      }

      switch action {
      case .alertDismissed:
        state.alert = nil

      case .submitButtonTapped:
        if state.isLoading {
          state.isLoading = false
          return EffectTask.cancel(id: EffectToken.login)
        } else {
          return performLogin()
        }

      case let .showPopoverTapped(popover):
        state.focusedField = nil
        state.popover = popover

      case .fieldSubmitted(.address):
        state.focusedField = .password

      case .fieldSubmitted(.password):
        return performLogin()

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
          title: TextState(L10n.Authentication.BasicAuth.Error.title),
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
