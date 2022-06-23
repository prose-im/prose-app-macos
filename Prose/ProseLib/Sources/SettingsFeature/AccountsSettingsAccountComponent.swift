//
//  AccountsSettingsAccountComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 12/12/21.
//

import AppLocalization
import SwiftUI

private let l10n = L10n.Settings.Accounts.self

struct AccountsSettingsAccountComponent: View {
    @AppStorage("settings.accounts.x.account.enabled") var enabled = true
    @AppStorage("settings.accounts.x.account.username") var username = ""
    @AppStorage("settings.accounts.x.account.password") var password = ""

    var body: some View {
        Toggle(isOn: $enabled) {
            SettingsFormFieldLabelComponent(
                label: l10n.enabledLabel
            )
        }
        .toggleStyle(.switch)

        Divider()

        SettingsFormFieldComponent(label: l10n.statusLabel) {
            HStack(spacing: 4) {
                ConnectionStatusIndicator(
                    status: .connected
                )

                Text(l10n.statusConnected)
                    .font(.system(size: 13))
                    .fontWeight(.semibold)
            }
        }

        Divider()

        Form {
            TextField(text: $username, prompt: Text(l10n.addressPlaceholder)) {
                SettingsFormFieldLabelComponent(
                    label: l10n.addressLabel
                )
            }
            .disableAutocorrection(true)

            SecureField(text: $password, prompt: Text(l10n.passwordPlaceholder)) {
                SettingsFormFieldLabelComponent(
                    label: l10n.passwordLabel
                )
            }
        }
        .textFieldStyle(.roundedBorder)
    }
}

struct AccountsSettingsAccountComponent_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AccountsSettingsAccountComponent()
        }
    }
}
