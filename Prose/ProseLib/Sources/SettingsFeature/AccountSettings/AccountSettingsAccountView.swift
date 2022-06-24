//
//  AccountSettingsAccountView.swift
//  Prose
//
//  Created by Valerian Saliou on 12/12/21.
//

import AppLocalization
import SwiftUI

private let l10n = L10n.Settings.Accounts.self

struct AccountSettingsAccountView: View {
    @AppStorage("settings.accounts.x.account.enabled") var enabled = true
    @AppStorage("settings.accounts.x.account.username") var username = ""
    @AppStorage("settings.accounts.x.account.password") var password = ""

    var body: some View {
        VStack(spacing: 24) {
            GroupBox(l10n.enabledLabel) {
                Toggle("", isOn: $enabled)
                    .toggleStyle(.switch)
                    .labelsHidden()
            }

            GroupBox(l10n.statusLabel) {
                HStack(spacing: 4) {
                    ConnectionStatusIndicator(status: .connected)
                    Text(l10n.statusConnected)
                        .font(.system(size: 13))
                        .fontWeight(.semibold)
                }
            }

            VStack {
                GroupBox(l10n.addressLabel) {
                    TextField("", text: $username, prompt: Text(l10n.addressPlaceholder))
                        .textContentType(.username)
                        .disableAutocorrection(true)
                }

                GroupBox(l10n.passwordLabel) {
                    SecureField("", text: $password, prompt: Text(l10n.passwordPlaceholder))
                        .textContentType(.password)
                }
            }

            Spacer()
        }
        .groupBoxStyle(FormGroupBoxStyle(firstColumnWidth: SettingsConstants.firstFormColumnConstrainedWidth))
        .padding()
    }
}

struct AccountSettingsAccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettingsAccountView()
    }
}
