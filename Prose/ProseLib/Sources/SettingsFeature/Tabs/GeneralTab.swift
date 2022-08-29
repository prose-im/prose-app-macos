//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import Assets
import ProseUI
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

struct GeneralTab: View {
  @AppStorage("settings.general.theme") var theme: GeneralSettingsTheme = .matchSystem
  @AppStorage("settings.general.downloadsPath") var downloadsPath = 0
  @AppStorage("settings.general.phoneFromAddressBook") var phoneFromAddressBook = false
  @AppStorage("settings.general.automaticallyMarkAwayEnabled") var automaticallyMarkAwayEnabled =
    false
  @AppStorage(
    "settings.general.automaticallyMarkAwayAfter"
  ) var automaticallyMarkAwayAfter: GeneralSettingsAutomaticallyMarkAwayAfter =
    .fifteenMinutes

  var body: some View {
    VStack(spacing: 24) {
      // "Theme"
      GroupBox(l10n.themeLabel) {
        Picker("", selection: $theme) {
          ForEach(GeneralSettingsTheme.allCases, id: \.self) { value in
            Text(value.localizedDescription)
              .tag(value)
          }
        }
        .labelsHidden()
        .frame(width: SettingsConstants.selectNormalWidth)
      }

      // "Save downloads to"
      GroupBox(l10n.downloadsLabel) {
        Picker("", selection: $downloadsPath) {
          // TODO: Choose from file system
        }
        .labelsHidden()
        .frame(width: SettingsConstants.selectNormalWidth)
      }

      // "Phone contacts"
      GroupBox(l10n.phoneLabel) {
        Toggle(isOn: $phoneFromAddressBook) {
          VStack(alignment: .leading) {
            Text(l10n.PhoneFromAddressBook.toggle)
            Text(l10n.PhoneFromAddressBook.description)
              .font(.caption)
          }
        }
      }

      // "When idle"
      GroupBox(l10n.idleLabel) {
        Toggle(
          l10n.IdleAutomaticallyMarkAway.enabledToggle,
          isOn: $automaticallyMarkAwayEnabled
        )
        Picker(
          l10n.IdleAutomaticallyMarkAway.afterLabel,
          selection: $automaticallyMarkAwayAfter
        ) {
          ForEach(
            GeneralSettingsAutomaticallyMarkAwayAfter.allCases,
            id: \.self
          ) { value in
            Text(value.localizedDescription)
              .tag(value)
          }
        }
        .frame(width: SettingsConstants.selectNormalWidth)
      }
    }
    .groupBoxStyle(FormGroupBoxStyle(
      firstColumnWidth: SettingsConstants.firstFormColumnWidth
    ))
    .padding()
    .disabled(true)
  }
}

struct GeneralTab_Previews: PreviewProvider {
  static var previews: some View {
    GeneralTab()
      .padding()
  }
}
