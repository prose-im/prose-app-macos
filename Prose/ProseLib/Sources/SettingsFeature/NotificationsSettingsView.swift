//
//  NotificationsSettingsView.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import Preferences
import SwiftUI

enum NotificationsSettingsNotify: String, Equatable, CaseIterable {
    case allMessages = "settings_notifications_notify_governor_option_all"
    case directMessages = "settings_notifications_notify_governor_option_direct"
    case none = "settings_notifications_notify_governor_option_none"

    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

enum NotificationsSettingsScheduleDays: String, Equatable, CaseIterable {
    case anytime = "settings_notifications_schedule_days_option_anytime"
    case weekdays = "settings_notifications_schedule_days_option_weekdays"
    case weekends = "settings_notifications_schedule_days_option_weekends"

    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

enum NotificationsSettingsScheduleTime: String, Equatable, CaseIterable {
    case morning = "settings_notifications_schedule_time_option_morning"
    case evening = "settings_notifications_schedule_time_option_evening"

    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

enum NotificationsSettingsHandoverForwardMobileAfter: String, Equatable, CaseIterable {
    case oneMinute = "settings_notifications_handover_forward_mobile_after_option_one_minute"
    case fiveMinutes = "settings_notifications_handover_forward_mobile_after_option_five_minutes"
    case tenMinutes = "settings_notifications_handover_forward_mobile_after_option_ten_minutes"

    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
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
                title: "settings_notifications_notify_governor_label".localized(),
                verticalAlignment: .top
            ) {
                Picker("", selection: $notifyGovernor) {
                    ForEach(NotificationsSettingsNotify.allCases, id: \.self) { value in
                        Text(value.localizedName)
                            .tag(value)
                    }
                }
                .labelsHidden()
                .frame(width: SettingsContants.selectNormalWidth)

                Toggle("settings_notifications_notify_on_reply_toggle".localized(), isOn: $notifyOnReply)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
            }

            // "Get notified"
            Preferences.Section(
                title: "settings_notifications_schedule_label".localized(),
                verticalAlignment: .top
            ) {
                Picker("", selection: $scheduleDays) {
                    ForEach(NotificationsSettingsScheduleDays.allCases, id: \.self) { value in
                        Text(value.localizedName)
                            .tag(value)
                    }
                }
                .labelsHidden()
                .frame(width: SettingsContants.selectNormalWidth)

                HStack {
                    Picker("", selection: $scheduleTimeFrom) {
                        ForEach(NotificationsSettingsScheduleTime.allCases, id: \.self) { value in
                            Text(value.localizedName)
                                .tag(value)
                        }
                    }
                    .labelsHidden()
                    .frame(width: SettingsContants.selectSmallWidth)

                    Text("settings_notifications_schedule_time_separator".localized())

                    Picker("", selection: $scheduleTimeTo) {
                        ForEach(NotificationsSettingsScheduleTime.allCases, id: \.self) { value in
                            Text(value.localizedName)
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
                title: "settings_notifications_action_label".localized(),
                verticalAlignment: .top
            ) {
                Toggle("settings_notifications_action_badge_toggle".localized(), isOn: $actionBadge)
                Toggle("settings_notifications_action_sound_toggle".localized(), isOn: $actionSound)
                Toggle("settings_notifications_action_banner_toggle".localized(), isOn: $actionBanner)

                Spacer()
            }

            // "Mobile alerts"
            Preferences.Section(
                title: "settings_notifications_handover_label".localized(),
                verticalAlignment: .top
            ) {
                Toggle("settings_notifications_handover_forward_mobile_toggle".localized(), isOn: $handoverForwardMobileEnabled)

                Picker("", selection: $handoverForwardMobileAfter) {
                    ForEach(NotificationsSettingsHandoverForwardMobileAfter.allCases, id: \.self) { value in
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

struct NotificationsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsSettingsView()
    }
}
