//
//  NotificationsSettingsViewController.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import AppLocalization
import Cocoa
import Preferences

let NotificationsSettingsViewController: () -> PreferencePane = {
    let paneView = Preferences.Pane(
        identifier: .notifications,
        title: L10n.Settings.Tabs.notifications,
        toolbarIcon: NSImage(systemSymbolName: "bell", accessibilityDescription: nil)!
    ) {
        NotificationsSettingsView()
    }

    return Preferences.PaneHostingController(pane: paneView)
}
