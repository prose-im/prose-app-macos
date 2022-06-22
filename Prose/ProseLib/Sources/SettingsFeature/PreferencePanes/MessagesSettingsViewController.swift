//
//  MessagesSettingsViewController.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import AppLocalization
import Cocoa
import Preferences

let MessagesSettingsViewController: () -> PreferencePane = {
    let paneView = Preferences.Pane(
        identifier: .messages,
        title: L10n.Settings.Tabs.messages,
        toolbarIcon: NSImage(systemSymbolName: "message", accessibilityDescription: nil)!
    ) {
        MessagesSettingsView()
    }

    return Preferences.PaneHostingController(pane: paneView)
}
