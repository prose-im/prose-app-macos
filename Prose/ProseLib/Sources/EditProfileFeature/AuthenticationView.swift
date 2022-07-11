//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import Assets
import ComposableArchitecture
import ProseUI
import SwiftUI

private let l10n = L10n.EditProfile.Authentication.self

// MARK: - View

struct AuthenticationView: View {
  typealias ViewState = AuthenticationState
  typealias ViewAction = AuthenticationAction

  let store: Store<ViewState, ViewAction>

  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      WithViewStore(self.store) { viewStore in
        VStack(spacing: 24) {
          ContentSection(
            header: l10n.PasswordSection.Header.label,
            footer: l10n.PasswordSection.Footer.label
          ) {
            VStack(alignment: .leading) {
              ThreeColumns(l10n.Password.Header.label) {
                Button { viewStore.send(.changePasswordTapped) } label: {
                  Text(verbatim: l10n.Password.ChangePasswordAction.label)
                    .frame(maxWidth: .infinity)
                }
                .controlSize(.large)
              }
              SecondaryRow(l10n.RecoveryEmail.Header.label) {
                Text(verbatim: viewStore.recoveryEmail)
                Button(l10n.RecoveryEmail.EditAction.label) {
                  viewStore.send(.editRecoveryEmailTapped)
                }
                .controlSize(.small)
              }
            }
            .padding(.horizontal)
          }
          Divider()
            .padding(.horizontal)
          ContentSection(
            header: l10n.MfaSection.Header.label,
            footer: l10n.MfaSection.Footer.label
          ) {
            VStack(alignment: .leading) {
              ThreeColumns(l10n.MfaToken.Header.label) {
                Button { viewStore.send(.disableMFATapped) } label: {
                  Text(verbatim: l10n.MfaToken.DisableMfaAction.label)
                    .frame(maxWidth: .infinity)
                }
                .controlSize(.large)
              }
              SecondaryRow(l10n.MfaStatus.Header.label) {
                HStack(spacing: 4) {
                  // TODO: Change this to a more general purpose indicator
                  OnlineStatusIndicator(viewStore.isMfaEnabled ? .online : .offline)
                    .accessibilityHidden(true)
                  Text(verbatim: viewStore.mfaStateLabel)
                }
                .accessibilityElement(children: .combine)
              }
              SecondaryRow(l10n.RecoveryPhone.Header.label) {
                Text(verbatim: viewStore.recoveryPhone)
                Button(l10n.RecoveryPhone.EditAction.label) {
                  viewStore.send(.editRecoveryPhoneTapped)
                }
                .controlSize(.small)
              }
            }
            .padding(.horizontal)
          }
        }
        .padding(.vertical, 24)
      }
    }
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let authenticationReducer = Reducer<
  AuthenticationState,
  AuthenticationAction,
  Void
> { state, action, _ in
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
}.binding()

// MARK: State

public struct AuthenticationState: Equatable {
  var recoveryEmail: String
  var recoveryPhone: String
  var isMfaEnabled: Bool

  var mfaStateLabel: String {
    self.isMfaEnabled
      ? l10n.MfaStatus.StateEnabled.label
      : l10n.MfaStatus.StateDisabled.label
  }

  public init(
    recoveryEmail: String = "baptiste@jamin.me",
    recoveryPhone: String = "+33631893345",
    isMfaEnabled: Bool = true
  ) {
    self.recoveryEmail = recoveryEmail
    self.recoveryPhone = recoveryPhone
    self.isMfaEnabled = isMfaEnabled
  }
}

// MARK: Actions

public enum AuthenticationAction: Equatable, BindableAction {
  case changePasswordTapped, editRecoveryEmailTapped, disableMFATapped, editRecoveryPhoneTapped
  case binding(BindingAction<AuthenticationState>)
}

// MARK: - Previews

struct AuthenticationView_Previews: PreviewProvider {
  static var previews: some View {
    AuthenticationView(store: Store(
      initialState: AuthenticationState(),
      reducer: authenticationReducer,
      environment: ()
    ))
    .frame(width: 480, height: 512)
  }
}
