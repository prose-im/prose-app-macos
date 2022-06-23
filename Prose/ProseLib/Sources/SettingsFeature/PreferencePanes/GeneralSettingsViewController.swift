//
//  GeneralSettingsViewController.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import AppLocalization
import Cocoa
import Preferences

let GeneralSettingsViewController: () -> PreferencePane = {
    let paneView = Preferences.Pane(
        identifier: .general,
        title: L10n.Settings.Tabs.general,
        toolbarIcon: NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil)!
    ) {
        GeneralSettingsView()
    }

    return Preferences.PaneHostingController(pane: paneView)
}
