//
//  AdvancedTab.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import AppLocalization
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

struct AdvancedTab: View {
    @AppStorage("settings.advanced.updateChannel") var updateChannel: AdvancedSettingsUpdateChannel = .stable
    @AppStorage("settings.advanced.reportsUsage") var reportsUsage = true
    @AppStorage("settings.advanced.reportsCrash") var reportsCrash = true

    var body: some View {
        VStack(spacing: 24) {
            // "Update channel"
            GroupBox(l10n.UpdateChannel.label) {
                Picker("", selection: $updateChannel) {
                    ForEach(AdvancedSettingsUpdateChannel.allCases, id: \.self) { value in
                        Text(value.localizedDescription)
                            .tag(value)
                    }
                }
                .labelsHidden()
                .frame(width: SettingsConstants.selectNormalWidth)
            }

            // "Reports"
            GroupBox(l10n.Reports.label) {
                Toggle(l10n.Reports.usageToggle, isOn: $reportsUsage)
                Toggle(l10n.Reports.crashToggle, isOn: $reportsCrash)
            }
        }
        .groupBoxStyle(FormGroupBoxStyle())
        .padding()
    }
}

struct AdvancedTab_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedTab()
    }
}
