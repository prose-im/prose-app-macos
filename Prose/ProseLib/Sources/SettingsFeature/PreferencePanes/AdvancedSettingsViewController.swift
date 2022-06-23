//
//  AdvancedSettingsViewController.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import AppLocalization
import Cocoa
import Preferences

let AdvancedSettingsViewController: () -> PreferencePane = {
    let paneView = Preferences.Pane(
        identifier: .advanced,
        title: L10n.Settings.Tabs.advanced,
        toolbarIcon: NSImage(systemSymbolName: "dial.min", accessibilityDescription: nil)!
    ) {
        AdvancedSettingsView()
    }

    return Preferences.PaneHostingController(pane: paneView)
}
