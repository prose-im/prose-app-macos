//
//  CallsSettingsViewController.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import AppLocalization
import Cocoa
import Preferences

let CallsSettingsViewController: () -> PreferencePane = {
    let paneView = Preferences.Pane(
        identifier: .calls,
        title: L10n.Settings.Tabs.calls,
        toolbarIcon: NSImage(systemSymbolName: "phone.arrow.up.right", accessibilityDescription: nil)!
    ) {
        CallsSettingsView(
            // TODO:
            videoInputStreamPath: "webcam-valerian"
        )
    }

    return Preferences.PaneHostingController(pane: paneView)
}
