//
//  GeneralSettingsView.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import AppLocalization
import Assets
import Preferences
import SwiftUI

private let l10n = L10n.Settings.General.self

enum GeneralSettingsTheme: String, Equatable, CaseIterable {
    case matchSystem = "match_system"
    case light
    case dark

    var localizedDescription: String {
        switch self {
        case .matchSystem:
            return l10n.themeOptionMatchSystem
        case .light:
            return l10n.themeOptionLight
        case .dark:
            return l10n.themeOptionDark
        }
    }
}

enum GeneralSettingsAutomaticallyMarkAwayAfter: String, Equatable, CaseIterable {
    case fiveMinutes = "five_minutes"
    case tenMinutes = "ten_minutes"
    case fifteenMinutes = "fifteen_minutes"
    case thirtyMinutes = "thirty_minutes"
    case oneHour = "one_hour"

    var localizedDescription: String {
        switch self {
        case .fiveMinutes:
            return l10n.IdleAutomaticallyMarkAway.afterOptionFiveMinutes
        case .tenMinutes:
            return l10n.IdleAutomaticallyMarkAway.afterOptionTenMinutes
        case .fifteenMinutes:
            return l10n.IdleAutomaticallyMarkAway.afterOptionFifteenMinutes
        case .thirtyMinutes:
            return l10n.IdleAutomaticallyMarkAway.afterOptionThirtyMinutes
        case .oneHour:
            return l10n.IdleAutomaticallyMarkAway.afterOptionOneHour
        }
    }
}

struct GeneralSettingsView: View {
    @AppStorage("settings.general.theme") var theme: GeneralSettingsTheme = .matchSystem
    @AppStorage("settings.general.downloadsPath") var downloadsPath = 0
    @AppStorage("settings.general.phoneFromAddressBook") var phoneFromAddressBook = false
    @AppStorage("settings.general.automaticallyMarkAwayEnabled") var automaticallyMarkAwayEnabled = false
    @AppStorage("settings.general.automaticallyMarkAwayAfter") var automaticallyMarkAwayAfter: GeneralSettingsAutomaticallyMarkAwayAfter = .fifteenMinutes

    var body: some View {
        Preferences.Container(contentWidth: SettingsContants.contentWidth) {
            // "Theme"
            Preferences.Section(
                title: l10n.themeLabel,
                verticalAlignment: .top
            ) {
                Picker("", selection: $theme) {
                    ForEach(GeneralSettingsTheme.allCases, id: \.self) { value in
                        Text(value.localizedDescription)
                            .tag(value)
                    }
                }
                .labelsHidden()
                .frame(width: SettingsContants.selectNormalWidth)

                Spacer()
            }

            // "Save downloads to"
            Preferences.Section(
                title: l10n.downloadsLabel,
                verticalAlignment: .top
            ) {
                Picker("", selection: $downloadsPath) {
                    // TODO:
                }
                .labelsHidden()
                .frame(width: SettingsContants.selectNormalWidth)

                Spacer()
            }

            // "Phone contacts"
            Preferences.Section(
                title: l10n.phoneLabel,
                verticalAlignment: .top
            ) {
                Toggle(l10n.PhoneFromAddressBook.toggle, isOn: $phoneFromAddressBook)

                Text(l10n.PhoneFromAddressBook.description)
                    .preferenceDescription()

                Spacer()
            }

            // "When idle"
            Preferences.Section(
                title: l10n.idleLabel,
                verticalAlignment: .top
            ) {
                Toggle(l10n.IdleAutomaticallyMarkAway.enabledToggle, isOn: $automaticallyMarkAwayEnabled)

                Picker("", selection: $automaticallyMarkAwayAfter) {
                    ForEach(GeneralSettingsAutomaticallyMarkAwayAfter.allCases, id: \.self) { value in
                        Text(value.localizedDescription)
                            .tag(value)
                    }
                }
                .labelsHidden()
                .frame(width: SettingsContants.selectNormalWidth)
            }
        }
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
