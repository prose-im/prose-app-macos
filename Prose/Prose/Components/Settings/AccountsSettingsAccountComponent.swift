//
//  AccountsSettingsAccountComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 12/12/21.
//

import SwiftUI

struct AccountsSettingsAccountComponent: View {
    @AppStorage("settings.accounts.x.account.enabled") var enabled = true
    @AppStorage("settings.accounts.x.account.username") var username = ""
    @AppStorage("settings.accounts.x.account.password") var password = ""
    
    var body: some View {
        Toggle(isOn: $enabled) {
            SettingsFormFieldLabelComponent(
                label: "settings_accounts_enabled_label".localized()
            )
        }
            .toggleStyle(.switch)
        
        Divider()
        
        SettingsFormFieldComponent(label: "settings_accounts_status_label".localized()) {
            HStack(spacing: 4) {
                CommonConnectionStatusComponent(
                    status: .connected
                )
                
                Text("settings_accounts_status_connected".localized())
                    .font(.system(size: 13))
                    .fontWeight(.semibold)
            }
        }
    
        Divider()
        
        Form {
            TextField(text: $username, prompt: Text("settings_accounts_address_placeholder".localized())) {
                SettingsFormFieldLabelComponent(
                    label: "settings_accounts_address_label".localized()
                )
            }
                .disableAutocorrection(true)
            
            SecureField(text: $password, prompt: Text("settings_accounts_password_placeholder".localized())) {
                SettingsFormFieldLabelComponent(
                    label: "settings_accounts_password_label".localized()
                )
            }
        }
            .textFieldStyle(.roundedBorder)
    }
}

struct AccountsSettingsAccountComponent_Previews: PreviewProvider {
    static var previews: some View {
        AccountsSettingsAccountComponent()
    }
}
