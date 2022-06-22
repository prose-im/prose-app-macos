//
//  AdvancedSettingsView.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import AppLocalization
import Preferences
import SwiftUI

private let l10n = L10n.Settings.Advanced.self

enum AdvancedSettingsUpdateChannel: String, Equatable, CaseIterable {
    case stable
    case beta

    var localizedDescription: String {
        switch self {
        case .stable:
            return l10n.UpdateChannel.optionStable
        case .beta:
            return l10n.UpdateChannel.optionBeta
        }
    }
}

struct AdvancedSettingsView: View {
    @AppStorage("settings.advanced.updateChannel") var updateChannel: AdvancedSettingsUpdateChannel = .stable
    @AppStorage("settings.advanced.reportsUsage") var reportsUsage = true
    @AppStorage("settings.advanced.reportsCrash") var reportsCrash = true

    var body: some View {
        Preferences.Container(contentWidth: SettingsContants.contentWidth) {
            // "Update channel"
            Preferences.Section(
                title: l10n.UpdateChannel.label,
                verticalAlignment: .top
            ) {
                Picker("", selection: $updateChannel) {
                    ForEach(AdvancedSettingsUpdateChannel.allCases, id: \.self) { value in
                        Text(value.localizedDescription)
                            .tag(value)
                    }
                }
                .labelsHidden()
                .frame(width: SettingsContants.selectNormalWidth)

                Spacer()
            }

            // "Reports"
            Preferences.Section(
                title: l10n.Reports.label,
                verticalAlignment: .top
            ) {
                Toggle(l10n.Reports.usageToggle, isOn: $reportsUsage)
                Toggle(l10n.Reports.crashToggle, isOn: $reportsCrash)
            }
        }
    }
}

struct AdvancedSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedSettingsView()
    }
}
