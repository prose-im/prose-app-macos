//
//  AdvancedSettingsView.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import Preferences
import SwiftUI

enum AdvancedSettingsUpdateChannel: String, Equatable, CaseIterable {
    case stable = "settings_advanced_update_channel_option_stable"
    case beta = "settings_advanced_update_channel_option_beta"

    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

struct AdvancedSettingsView: View {
    @AppStorage("settings.advanced.updateChannel") var updateChannel: AdvancedSettingsUpdateChannel = .stable
    @AppStorage("settings.advanced.reportsUsage") var reportsUsage = true
    @AppStorage("settings.advanced.reportsCrash") var reportsCrash = true

    var body: some View {
        Preferences.Container(contentWidth: SettingsContants.contentWidth) {
            // "Update channel"
            Preferences.Section(
                title: "settings_advanced_update_channel_label".localized(),
                verticalAlignment: .top
            ) {
                Picker("", selection: $updateChannel) {
                    ForEach(AdvancedSettingsUpdateChannel.allCases, id: \.self) { value in
                        Text(value.localizedName)
                            .tag(value)
                    }
                }
                .labelsHidden()
                .frame(width: SettingsContants.selectNormalWidth)

                Spacer()
            }

            // "Reports"
            Preferences.Section(
                title: "settings_advanced_reports_label".localized(),
                verticalAlignment: .top
            ) {
                Toggle("settings_advanced_reports_usage_toggle".localized(), isOn: $reportsUsage)
                Toggle("settings_advanced_reports_crash_toggle".localized(), isOn: $reportsCrash)
            }
        }
    }
}

struct AdvancedSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedSettingsView()
    }
}
