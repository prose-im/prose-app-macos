//
//  GeneralSettingsView.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import SwiftUI
import Preferences

struct GeneralSettingsView: View {
    @AppStorage("settings.general.theme") var themeSelection = 0
    @AppStorage("settings.general.downloadsPath") var downloadsPath = 0
    @AppStorage("settings.general.phoneFromAddressBook") var phoneFromAddressBook = false
    @AppStorage("settings.general.automaticallyMarkAwayEnabled") var automaticallyMarkAwayEnabled = false
    @AppStorage("settings.general.automaticallyMarkAwayAfter") var automaticallyMarkAwayAfter = 0
    
    var body: some View {
        Preferences.Container(contentWidth: SettingsContants.contentWidth) {
            // TODO: translate everything
            
            Preferences.Section(title: "Theme:") {
                Picker("", selection: $themeSelection) {
                    Text("Match system").tag(0)
                }
                .labelsHidden()
                .frame(width: SettingsContants.selectWidth)
            }
            
            Preferences.Section(title: "Save downloads to:") {
                Picker("", selection: $downloadsPath) {
                    Text("(...)").tag(0)
                }
                .labelsHidden()
                .frame(width: SettingsContants.selectWidth)
            }
            
            Preferences.Section(title: "Phone contacts:") {
                Toggle("Use phone numbers from my address book", isOn: $phoneFromAddressBook)
                
                Text("This is for local use only. Data does not get sent to a server.")
                    .preferenceDescription()
            }
            
            Preferences.Section(title: "When idle:") {
                Toggle("Automatically mark me as away after:", isOn: $automaticallyMarkAwayEnabled)
                
                Picker("", selection: $automaticallyMarkAwayAfter) {
                    Text("5 minutes").tag(0)
                }
                .labelsHidden()
                .frame(width: SettingsContants.selectWidth)
            }
        }
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
