//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture

public struct AuthenticationReducer: ReducerProtocol {
  public struct State: Equatable {
    var recoveryEmail = "baptiste@jamin.me"
    var recoveryPhone = "+33631893345"
    var isMfaEnabled = false

    var mfaStateLabel: String {
      self.isMfaEnabled
        ? L10n.EditProfile.Authentication.MfaStatus.StateEnabled.label
        : L10n.EditProfile.Authentication.MfaStatus.StateDisabled.label
    }

    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case changePasswordTapped
    case editRecoveryEmailTapped
    case disableMFATapped
    case editRecoveryPhoneTapped
    case binding(BindingAction<State>)
  }

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    self.core
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .changePasswordTapped:
        logger.trace("Change password tapped")
        return .none

      case .editRecoveryEmailTapped:
        logger.trace("Edit recovery email tapped")
        return .none

      case .disableMFATapped:
        state.isMfaEnabled.toggle()
        return .none

      case .editRecoveryPhoneTapped:
        logger.trace("Edit recovery phone tapped")
        return .none

      case .binding:
        return .none
      }
    }
  }
}
