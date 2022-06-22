//
//  AccountsSettingsTabsComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 12/12/21.
//

import AppLocalization
import SwiftUI

private let l10n = L10n.Settings.Accounts.self

struct AccountsSettingsTabsComponent: View {
    @Binding var selection: AccountsSettingsTab

    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()

                Picker("", selection: $selection, content: {
                    Text(l10n.Tabs.account).tag(AccountsSettingsTab.account)
                    Text(l10n.Tabs.security).tag(AccountsSettingsTab.security)
                    Text(l10n.Tabs.features).tag(AccountsSettingsTab.features)
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
