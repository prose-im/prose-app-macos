//
//  GeneralSettingsView.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import SwiftUI
import Preferences

enum GeneralSettingsTheme: String, Equatable, CaseIterable {
    case matchSystem = "settings_general_theme_option_match_system"
    case light = "settings_general_theme_option_light"
    case dark = "settings_general_theme_option_dark"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

enum GeneralSettingsAutomaticallyMarkAwayAfter: String, Equatable, CaseIterable {
    case fiveMinutes = "settings_general_idle_automatically_mark_away_after_option_five_minutes"
    case tenMinutes = "settings_general_idle_automatically_mark_away_after_option_ten_minutes"
    case fifteenMinutes = "settings_general_idle_automatically_mark_away_after_option_fifteen_minutes"
    case thirtyMinutes = "settings_general_idle_automatically_mark_away_after_option_thirty_minutes"
    case oneHour = "settings_general_idle_automatically_mark_away_after_option_one_hour"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
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
            Preferences.Section(title: "settings_general_theme_label".localized()) {
                Picker("", selection: $theme) {
                    ForEach(GeneralSettingsTheme.allCases, id: \.self) { value in
                        Text(value.localizedName)
                            .tag(value)
                    }
                }
                .labelsHidden()
                .frame(width: SettingsContants.selectNormalWidth)
                
                Spacer()
            }
            
            // "Save downloads to"
            Preferences.Section(title: "settings_general_downloads_label".localized()) {
                Picker("", selection: $downloadsPath) {
                    Text("(...)").tag(0)
                }
                .labelsHidden()
                .frame(width: SettingsContants.selectNormalWidth)
                
                Spacer()
            }
            
            // "Phone contacts"
            Preferences.Section(title: "settings_general_phone_label".localized()) {
                Toggle("settings_general_phone_from_address_book_toggle".localized(), isOn: $phoneFromAddressBook)
                
                Text("settings_general_phone_from_address_book_description".localized())
                    .preferenceDescription()
                
                Spacer()
            }
            
            // "When idle"
            Preferences.Section(title: "settings_general_idle_label".localized()) {
                Toggle("settings_general_idle_automatically_mark_away_enabled_toggle".localized(), isOn: $automaticallyMarkAwayEnabled)
                
                Picker("", selection: $automaticallyMarkAwayAfter) {
                    ForEach(GeneralSettingsAutomaticallyMarkAwayAfter.allCases, id: \.self) { value in
                        Text(value.localizedName)
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
