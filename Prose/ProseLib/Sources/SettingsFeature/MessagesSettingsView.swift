//
//  MessagesSettingsView.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import AppLocalization
import Preferences
import SwiftUI

private let l10n = L10n.Settings.Messages.self

enum MessagesSettingsThumbnailsSize: String, Equatable, CaseIterable {
    case small
    case large

    var localizedDescription: String {
        switch self {
        case .small:
            return l10n.Thumbnails.sizeOptionSmall
        case .large:
            return l10n.Thumbnails.sizeOptionLarge
        }
    }
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
            Preferences.Section(
                title: l10n.Composing.label,
                verticalAlignment: .top
            ) {
                Toggle(l10n.Composing.showWhenTypingToggle, isOn: $composingShowWhenTyping)
                Toggle(l10n.Composing.spellCheckToggle, isOn: $composingSpellCheck)

                Spacer()
            }

            // "Messages"
            Preferences.Section(
                title: l10n.Messages.label,
                verticalAlignment: .top
            ) {
                Toggle(l10n.Messages._24HourClockToggle, isOn: $messages24HourClock)
                Toggle(l10n.Messages.imagePreviewsToggle, isOn: $messagesImagePreviews)

                Spacer()
            }

            // "Image thumbnails"
            Preferences.Section(
                title: l10n.Thumbnails.label,
                verticalAlignment: .top
            ) {
                Picker("", selection: $thumbnailsSize) {
                    ForEach(MessagesSettingsThumbnailsSize.allCases, id: \.self) { value in
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

struct MessagesSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesSettingsView()
    }
}
