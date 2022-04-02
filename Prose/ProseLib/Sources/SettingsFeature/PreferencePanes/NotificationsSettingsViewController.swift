//
//  NotificationsSettingsViewController.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import Cocoa
import Preferences

let NotificationsSettingsViewController: () -> PreferencePane = {
    let paneView = Preferences.Pane(
        identifier: .notifications,
        title: "settings_tabs_notifications".localized(),
        toolbarIcon: NSImage(systemSymbolName: "bell", accessibilityDescription: "")!
    ) {
        NotificationsSettingsView()
    }
    
    return Preferences.PaneHostingController(pane: paneView)
}
