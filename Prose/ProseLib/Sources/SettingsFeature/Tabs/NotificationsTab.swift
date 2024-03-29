//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppLocalization
import SwiftUI

private let l10n = L10n.Settings.Notifications.self

enum NotificationsSettingsNotify: String, Equatable, CaseIterable {
  case allMessages = "all"
  case directMessages = "direct"
  case none

  var localizedDescription: String {
    switch self {
    case .allMessages:
      return l10n.NotifyGovernor.optionAll
    case .directMessages:
      return l10n.NotifyGovernor.optionDirect
    case .none:
      return l10n.NotifyGovernor.optionNone
    }
  }
}

enum NotificationsSettingsScheduleDays: String, Equatable, CaseIterable {
  case anytime
  case weekdays
  case weekends

  var localizedDescription: String {
    switch self {
    case .anytime:
      return l10n.Schedule.Days.optionAnytime
    case .weekdays:
      return l10n.Schedule.Days.optionWeekdays
    case .weekends:
      return l10n.Schedule.Days.optionWeekends
    }
  }
}

enum NotificationsSettingsScheduleTime: String, Equatable, CaseIterable {
  case morning
  case evening

  var localizedDescription: String {
    switch self {
    case .morning:
      return l10n.Schedule.timeOptionMorning
    case .evening:
      return l10n.Schedule.timeOptionEvening
    }
  }
}

enum NotificationsSettingsHandoverForwardMobileAfter: String, Equatable, CaseIterable {
  case oneMinute = "one_minute"
  case fiveMinutes = "five_minutes"
  case tenMinutes = "ten_minutes"

  var localizedDescription: String {
    switch self {
    case .oneMinute:
      return l10n.Handover.ForwardMobile.afterOptionOneMinute
    case .fiveMinutes:
      return l10n.Handover.ForwardMobile.afterOptionFiveMinutes
    case .tenMinutes:
      return l10n.Handover.ForwardMobile.afterOptionTenMinutes
    }
  }
}

struct NotificationsTab: View {
  @AppStorage(
    "settings.notifications.notifyGovernor"
  ) var notifyGovernor: NotificationsSettingsNotify =
    .allMessages
  @AppStorage("settings.notifications.notifyOnReply") var notifyOnReply = true
  @AppStorage(
    "settings.notifications.scheduleDays"
  ) var scheduleDays: NotificationsSettingsScheduleDays =
    .weekdays
  @AppStorage(
    "settings.notifications.scheduleTimeFrom"
  ) var scheduleTimeFrom: NotificationsSettingsScheduleTime =
    .morning
  @AppStorage(
    "settings.notifications.scheduleTimeTo"
  ) var scheduleTimeTo: NotificationsSettingsScheduleTime =
    .evening
  @AppStorage("settings.notifications.actionBadge") var actionBadge = true
  @AppStorage("settings.notifications.actionSound") var actionSound = true
  @AppStorage("settings.notifications.actionBanner") var actionBanner = true
  @AppStorage(
    "settings.notifications.handoverForwardMobileEnabled"
  ) var handoverForwardMobileEnabled =
    true
  @AppStorage(
    "settings.notifications.handoverForwardMobileAfter"
  ) var handoverForwardMobileAfter: NotificationsSettingsHandoverForwardMobileAfter =
    .fiveMinutes

  var body: some View {
    VStack {
      // "Notify me about"
      GroupBox(l10n.NotifyGovernor.label) {
        Picker("", selection: self.$notifyGovernor) {
          ForEach(NotificationsSettingsNotify.allCases, id: \.self) { value in
            Text(value.localizedDescription)
              .tag(value)
          }
        }
        .labelsHidden()
        .frame(width: SettingsConstants.selectNormalWidth)

        Toggle(l10n.NotifyOnReply.toggle, isOn: self.$notifyOnReply)
          .frame(maxWidth: .infinity, alignment: .leading)
      }

      // "Get notified"
      GroupBox(l10n.Schedule.label) {
        Picker("", selection: self.$scheduleDays) {
          ForEach(NotificationsSettingsScheduleDays.allCases, id: \.self) { value in
            Text(value.localizedDescription)
              .tag(value)
          }
        }
        .labelsHidden()
        .frame(width: SettingsConstants.selectNormalWidth)

        HStack {
          Picker("", selection: self.$scheduleTimeFrom) {
            ForEach(NotificationsSettingsScheduleTime.allCases, id: \.self) { value in
              Text(value.localizedDescription)
                .tag(value)
            }
          }
          .labelsHidden()
          .frame(width: SettingsConstants.selectSmallWidth)

          Text(l10n.Schedule.timeSeparator)

          Picker("", selection: self.$scheduleTimeTo) {
            ForEach(NotificationsSettingsScheduleTime.allCases, id: \.self) { value in
              Text(value.localizedDescription)
                .tag(value)
            }
          }
          .labelsHidden()
          .frame(width: SettingsConstants.selectSmallWidth)
        }
      }

      // "When notified"
      GroupBox(l10n.Action.label) {
        Toggle(l10n.Action.badgeToggle, isOn: self.$actionBadge)
        Toggle(l10n.Action.soundToggle, isOn: self.$actionSound)
        Toggle(l10n.Action.bannerToggle, isOn: self.$actionBanner)
      }

      // "Mobile alerts"
      GroupBox(l10n.Handover.label) {
        Toggle(l10n.Handover.ForwardMobile.toggle, isOn: self.$handoverForwardMobileEnabled)

        Picker("", selection: self.$handoverForwardMobileAfter) {
          ForEach(
            NotificationsSettingsHandoverForwardMobileAfter.allCases,
            id: \.self
          ) { value in
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

struct NotificationsTab_Previews: PreviewProvider {
  static var previews: some View {
    NotificationsTab()
  }
}
