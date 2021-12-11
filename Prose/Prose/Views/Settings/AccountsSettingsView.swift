//
//  AccountsSettingsView.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import SwiftUI
import Preferences

enum AccountsSettingsTab {
    case account
    case security
    case features
}

struct AccountsSettingsView: View {
    @State private var selectedTab: AccountsSettingsTab = .account
    
    @AppStorage("settings.accounts.x.enabled") var enabled = true
    @AppStorage("settings.accounts.x.username") var username = ""
    @AppStorage("settings.accounts.x.password") var password = ""
    
    var body: some View {
        // TODO: finish base structure
        
        HStack(spacing: 10) {
            // TODO: left bar
            GroupBox {
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Spacer()
                        
                        Picker("", selection: $selectedTab, content: {
                            Text("settings_accounts_tabs_account".localized()).tag(AccountsSettingsTab.account)
                            Text("settings_accounts_tabs_security".localized()).tag(AccountsSettingsTab.security)
                            Text("settings_accounts_tabs_features".localized()).tag(AccountsSettingsTab.features)
                        })
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(maxWidth: 280.0)
                        
                        Spacer()
                    }
                    
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
                .padding(.horizontal, 28)
                .padding(.bottom, 12)
                
            }
            .frame(maxWidth: .infinity)
        }
        .frame(width: SettingsContants.contentWidth, alignment: .leading)
        .padding(.vertical, 20)
        .padding(.horizontal, 30)
    }
}

struct AccountsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsSettingsView()
    }
}
