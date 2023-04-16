//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture

public struct IdentityReducer: ReducerProtocol {
  public struct State: Equatable {
    @BindingState var firstName: String
    @BindingState var lastName: String
    @BindingState var email: String
    @BindingState var phone: String

    @BindingState var isNameVerified: Bool
    @BindingState var isEmailVerified: Bool
    @BindingState var isPhoneVerified: Bool

    public init(
      firstName: String = "Baptiste",
      lastName: String = "Jamin",
      email: String = "baptiste@crisp.chat",
      phone: String = "+33631893345",
      isNameVerified: Bool = false,
      isEmailVerified: Bool = true,
      isPhoneVerified: Bool = false
    ) {
      self.firstName = firstName
      self.lastName = lastName
      self.email = email
      self.phone = phone
      self.isNameVerified = isNameVerified
      self.isEmailVerified = isEmailVerified
      self.isPhoneVerified = isPhoneVerified
    }
  }

  public enum Action: Equatable, BindableAction {
    case verifyNameTapped
    case verifyEmailTapped
    case verifyPhoneTapped
    case binding(BindingAction<State>)
  }

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    self.core
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .verifyNameTapped:
        state.isNameVerified = true
        return .none

      case .verifyEmailTapped:
        state.isEmailVerified = true
        return .none

      case .verifyPhoneTapped:
        state.isPhoneVerified = true
        return .none

      case .binding:
        return .none
      }
    }
  }
}
