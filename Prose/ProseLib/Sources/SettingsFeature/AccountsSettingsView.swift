//
//  AccountsSettingsView.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import Assets
import Preferences
import SwiftUI

enum AccountsSettingsTab {
    case account
    case security
    case features
}

struct AccountsSettingsView: View {
    @State private var selectedTab: AccountsSettingsTab = .account
    @State private var selectedAccount: String = ""

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 0) {
                List {
                    SettingsPickAccountComponent(
                        teamLogo: "logo-crisp",
                        teamDomain: "crisp.chat",
                        userName: "Baptiste"
                    )

                    SettingsPickAccountComponent(
                        teamLogo: "logo-makair",
                        teamDomain: "makair.life",
                        userName: "Baptiste"
                    )
                }
                .listStyle(PlainListStyle())

                Divider()

                HStack(spacing: 0) {
                    SettingsPickActionComponent(
                        actionName: "plus"
                    )

                    SettingsPickActionComponent(
                        actionName: "minus"
                    )

                    Spacer()
                }
                .frame(height: 22)
            }
            .frame(maxWidth: 140)
            .background(.white)
            .border(Asset.Color.Border.tertiaryLight.swiftUIColor)

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
