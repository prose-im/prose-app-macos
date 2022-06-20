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
        title: "settings_tabs_advanced".localized(),
        toolbarIcon: NSImage(systemSymbolName: "dial.min", accessibilityDescription: "")!
    ) {
        AdvancedSettingsView()
    }

    return Preferences.PaneHostingController(pane: paneView)
}
