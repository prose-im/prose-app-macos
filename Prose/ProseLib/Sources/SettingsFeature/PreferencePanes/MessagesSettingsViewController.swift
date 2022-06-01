//
//  MessagesSettingsViewController.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import Cocoa
import Preferences

let MessagesSettingsViewController: () -> PreferencePane = {
    let paneView = Preferences.Pane(
        identifier: .messages,
        title: "settings_tabs_messages".localized(),
        toolbarIcon: NSImage(systemSymbolName: "message", accessibilityDescription: "")!
    ) {
        MessagesSettingsView()
    }

    return Preferences.PaneHostingController(pane: paneView)
}
