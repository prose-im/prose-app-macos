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
    
    var body: some View {
        HStack(spacing: 10) {
            // TODO: left bar
            GroupBox {
                VStack(alignment: .leading, spacing: 22) {
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
                    
                    VStack(alignment: .leading, spacing: 18) {
                        switch selectedTab {
                        case .account:
                            AccountsSettingsAccountComponent()
                            
                        case .security:
                            AccountsSettingsSecurityComponent()
                            
                        case .features:
                            AccountsSettingsFeaturesComponent()
                        }
                    }
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
