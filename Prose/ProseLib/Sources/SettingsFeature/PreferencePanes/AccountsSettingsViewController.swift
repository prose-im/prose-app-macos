//
//  AccountsSettingsViewController.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import AppLocalization
import Cocoa
import Preferences

let AccountsSettingsViewController: () -> PreferencePane = {
    let paneView = Preferences.Pane(
        identifier: .accounts,
        title: L10n.Settings.Tabs.accounts,
        toolbarIcon: NSImage(systemSymbolName: "person.2", accessibilityDescription: nil)!
    ) {
        AccountsSettingsView()
    }

    return Preferences.PaneHostingController(pane: paneView)
}
