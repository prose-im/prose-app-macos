//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppLocalization
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

struct MessagesTab: View {
  @AppStorage("settings.messages.composingShowWhenTyping") var composingShowWhenTyping = true
  @AppStorage("settings.messages.composingSpellCheck") var composingSpellCheck = false
  @AppStorage("settings.messages.messages24HourClock") var messages24HourClock = false
  @AppStorage("settings.messages.messagesImagePreviews") var messagesImagePreviews = true
  @AppStorage(
    "settings.messages.thumbnailsSize"
  ) var thumbnailsSize: MessagesSettingsThumbnailsSize =
    .large

  var body: some View {
    VStack(spacing: 24) {
      // "Composing"
      GroupBox(l10n.Composing.label) {
        Toggle(l10n.Composing.showWhenTypingToggle, isOn: self.$composingShowWhenTyping)
        Toggle(l10n.Composing.spellCheckToggle, isOn: self.$composingSpellCheck)
      }

      // "Messages"
      GroupBox(l10n.Messages.label) {
        Toggle(l10n.Messages._24HourClockToggle, isOn: self.$messages24HourClock)
        Toggle(l10n.Messages.imagePreviewsToggle, isOn: self.$messagesImagePreviews)
      }

      // "Image thumbnails"
      GroupBox(l10n.Thumbnails.label) {
        Picker("", selection: self.$thumbnailsSize) {
          ForEach(MessagesSettingsThumbnailsSize.allCases, id: \.self) { value in
            Text(value.localizedDescription)
              .tag(value)
          }
        }
        .labelsHidden()
        .frame(width: SettingsConstants.selectNormalWidth)
      }
    }
    .groupBoxStyle(FormGroupBoxStyle())
    .padding()
    .disabled(true)
  }
}

struct MessagesTab_Previews: PreviewProvider {
  static var previews: some View {
    MessagesTab()
  }
}
