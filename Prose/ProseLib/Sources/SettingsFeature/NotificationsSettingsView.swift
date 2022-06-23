//
//  NotificationsSettingsView.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import AppLocalization
import Preferences
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

struct NotificationsSettingsView: View {
    @AppStorage("settings.notifications.notifyGovernor") var notifyGovernor: NotificationsSettingsNotify = .allMessages
    @AppStorage("settings.notifications.notifyOnReply") var notifyOnReply = true
    @AppStorage("settings.notifications.scheduleDays") var scheduleDays: NotificationsSettingsScheduleDays = .weekdays
    @AppStorage("settings.notifications.scheduleTimeFrom") var scheduleTimeFrom: NotificationsSettingsScheduleTime = .morning
    @AppStorage("settings.notifications.scheduleTimeTo") var scheduleTimeTo: NotificationsSettingsScheduleTime = .evening
    @AppStorage("settings.notifications.actionBadge") var actionBadge = true
    @AppStorage("settings.notifications.actionSound") var actionSound = true
    @AppStorage("settings.notifications.actionBanner") var actionBanner = true
    @AppStorage("settings.notifications.handoverForwardMobileEnabled") var handoverForwardMobileEnabled = true
    @AppStorage("settings.notifications.handoverForwardMobileAfter") var handoverForwardMobileAfter: NotificationsSettingsHandoverForwardMobileAfter = .fiveMinutes

    var body: some View {
        Preferences.Container(contentWidth: SettingsContants.contentWidth) {
            // "Notify me about"
            Preferences.Section(
                title: l10n.NotifyGovernor.label,
                verticalAlignment: .top
            ) {
                Picker("", selection: $notifyGovernor) {
                    ForEach(NotificationsSettingsNotify.allCases, id: \.self) { value in
                        Text(value.localizedDescription)
                            .tag(value)
                    }
                }
                .labelsHidden()
                .frame(width: SettingsContants.selectNormalWidth)

                Toggle(l10n.NotifyOnReply.toggle, isOn: $notifyOnReply)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
            }

            // "Get notified"
            Preferences.Section(
                title: l10n.Schedule.label,
                verticalAlignment: .top
            ) {
                Picker("", selection: $scheduleDays) {
                    ForEach(NotificationsSettingsScheduleDays.allCases, id: \.self) { value in
                        Text(value.localizedDescription)
                            .tag(value)
                    }
                }
                .labelsHidden()
                .frame(width: SettingsContants.selectNormalWidth)

                HStack {
                    Picker("", selection: $scheduleTimeFrom) {
                        ForEach(NotificationsSettingsScheduleTime.allCases, id: \.self) { value in
                            Text(value.localizedDescription)
                                .tag(value)
                        }
                    }
                    .labelsHidden()
                    .frame(width: SettingsContants.selectSmallWidth)

                    Text(l10n.Schedule.timeSeparator)

                    Picker("", selection: $scheduleTimeTo) {
                        ForEach(NotificationsSettingsScheduleTime.allCases, id: \.self) { value in
                            Text(value.localizedDescription)
                                .tag(value)
                        }
                    }
                    .labelsHidden()
                    .frame(width: SettingsContants.selectSmallWidth)
                }

                Spacer()
            }

            // "When notified"
            Preferences.Section(
                title: l10n.Action.label,
                verticalAlignment: .top
            ) {
                Toggle(l10n.Action.badgeToggle, isOn: $actionBadge)
                Toggle(l10n.Action.soundToggle, isOn: $actionSound)
                Toggle(l10n.Action.bannerToggle, isOn: $actionBanner)

                Spacer()
            }

            // "Mobile alerts"
            Preferences.Section(
                title: l10n.Handover.label,
                verticalAlignment: .top
            ) {
                Toggle(l10n.Handover.ForwardMobile.toggle, isOn: $handoverForwardMobileEnabled)

                Picker("", selection: $handoverForwardMobileAfter) {
                    ForEach(NotificationsSettingsHandoverForwardMobileAfter.allCases, id: \.self) { value in
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

struct NotificationsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsSettingsView()
    }
}
