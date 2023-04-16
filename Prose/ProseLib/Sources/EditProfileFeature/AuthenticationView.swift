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

struct AuthenticationView: View {
  let store: StoreOf<AuthenticationReducer>

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
                  LEDIndicator(isOn: viewStore.isMfaEnabled)
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
