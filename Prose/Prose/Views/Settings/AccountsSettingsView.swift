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
    @State private var selectedAccount: String = ""
    
    var body: some View {
        let actionNames = ["plus", "minus"]
        
        HStack(spacing: 12) {
            VStack(spacing: 0) {
                ScrollView {
                    List {
                        // TODO
                    }
                }
                
                Divider()
                
                HStack(spacing: 0) {
                    ForEach(actionNames, id: \.self) { actionName in
                        Button(action: {}) {
                            Image(systemName: actionName)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .buttonStyle(.plain)
                        .frame(width: 26, alignment: .center)
                        
                        Divider()
                            
                    }
                    .padding(.vertical, 3.0)
                    
                    Spacer()
                }
                .frame(height: 22)
            }
            .frame(maxWidth: 140)
            .background(.white)
            .border(Color.borderTertiaryLight, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
            
            GroupBox(
                label: AccountsSettingsTabsComponent(
                    selection: $selectedTab
                )
                    .zIndex(1)
            ) {
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
                .padding(.horizontal, 28)
                .padding(.top, 24)
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity, alignment: .top)
                
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
