//
//  MessagesSettingsView.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import SwiftUI
import Preferences

enum MessagesSettingsThumbnailsSize: String, Equatable, CaseIterable {
    case small = "settings_messages_thumbnails_size_option_small"
    case large = "settings_messages_thumbnails_size_option_large"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

struct MessagesSettingsView: View {
    @AppStorage("settings.messages.composingShowWhenTyping") var composingShowWhenTyping = true
    @AppStorage("settings.messages.composingSpellCheck") var composingSpellCheck = false
    @AppStorage("settings.messages.messages24HourClock") var messages24HourClock = false
    @AppStorage("settings.messages.messagesImagePreviews") var messagesImagePreviews = true
    @AppStorage("settings.messages.thumbnailsSize") var thumbnailsSize: MessagesSettingsThumbnailsSize = .large
    
    var body: some View {
        Preferences.Container(contentWidth: SettingsContants.contentWidth) {
            // "Composing"
            Preferences.Section(title: "settings_messages_composing_label".localized()) {
                Toggle("settings_messages_composing_show_when_typing_toggle".localized(), isOn: $composingShowWhenTyping)
                Toggle("settings_messages_composing_spell_check_toggle".localized(), isOn: $composingSpellCheck)
                
                Spacer()
            }
            
            // "Messages"
            Preferences.Section(title: "settings_messages_messages_label".localized()) {
                Toggle("settings_messages_messages_24_hour_clock_toggle".localized(), isOn: $messages24HourClock)
                Toggle("settings_messages_messages_image_previews_toggle".localized(), isOn: $messagesImagePreviews)
                
                Spacer()
            }
            
            // "Image thumbnails"
            Preferences.Section(title: "settings_messages_thumbnails_label".localized()) {
                Picker("", selection: $thumbnailsSize) {
                    ForEach(MessagesSettingsThumbnailsSize.allCases, id: \.self) { value in
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

struct MessagesSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesSettingsView()
    }
}
