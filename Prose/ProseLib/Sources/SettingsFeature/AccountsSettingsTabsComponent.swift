//
//  AccountsSettingsTabsComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 12/12/21.
//

import SwiftUI

struct AccountsSettingsTabsComponent: View {
    @Binding var selection: AccountsSettingsTab

    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()

                Picker("", selection: $selection, content: {
                    Text("settings_accounts_tabs_account".localized()).tag(AccountsSettingsTab.account)
                    Text("settings_accounts_tabs_security".localized()).tag(AccountsSettingsTab.security)
                    Text("settings_accounts_tabs_features".localized()).tag(AccountsSettingsTab.features)
                })
                .pickerStyle(SegmentedPickerStyle())
                .labelsHidden()
                .frame(maxWidth: 280.0)

                Spacer()
            }
            .offset(x: 0, y: (geometry.size.height / 2) - 3.0)
        }
    }
}

struct AccountsSettingsTabsComponent_Previews: PreviewProvider {
    @State static var selection = AccountsSettingsTab.account

    static var previews: some View {
        AccountsSettingsTabsComponent(
            selection: $selection
        )
    }
}
