//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import Assets
import ProseUI
import SwiftUI

private let l10n = L10n.EditProfile.Authentication.self

struct AuthenticationView: View {
  let recoveryEmail: String = "baptiste@jamin.me"
  let recoveryPhone: String = "+33631893345"
  var isMfaEnabled: Bool = true

  var mfaStateLabel: String {
    self.isMfaEnabled
      ? l10n.MfaStatus.StateEnabled.label
      : l10n.MfaStatus.StateDisabled.label
  }

  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack(spacing: 24) {
        ContentSection(
          header: l10n.PasswordSection.Header.label,
          footer: l10n.PasswordSection.Footer.label
        ) {
          VStack(alignment: .leading) {
            ThreeColumns(l10n.Password.Header.label) {
              Button { logger.trace("Change password tapped") } label: {
                Text(verbatim: l10n.Password.ChangePasswordAction.label)
                  .frame(maxWidth: .infinity)
              }
              .controlSize(.large)
            }
            SecondaryRow(l10n.RecoveryEmail.Header.label) {
              Text(verbatim: self.recoveryEmail)
              Button(l10n.RecoveryEmail.EditAction.label) {
                logger.trace("Edit recovery email tapped")
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
              Button { logger.trace("Disable MFA tapped") } label: {
                Text(verbatim: l10n.MfaToken.DisableMfaAction.label)
                  .frame(maxWidth: .infinity)
              }
              .controlSize(.large)
            }
            SecondaryRow(l10n.MfaStatus.Header.label) {
              HStack(spacing: 4) {
                // TODO: Change this to a more general purpose indicator
                OnlineStatusIndicator(.online)
                  .accessibilityHidden(true)
                Text(verbatim: self.mfaStateLabel)
              }
              .accessibilityElement(children: .combine)
            }
            SecondaryRow(l10n.RecoveryPhone.Header.label) {
              Text(verbatim: self.recoveryPhone)
              Button(l10n.RecoveryPhone.EditAction.label) {
                logger.trace("Edit recovery phone tapped")
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

struct AuthenticationView_Previews: PreviewProvider {
  static var previews: some View {
    AuthenticationView()
      .frame(width: 480, height: 512)
  }
}
