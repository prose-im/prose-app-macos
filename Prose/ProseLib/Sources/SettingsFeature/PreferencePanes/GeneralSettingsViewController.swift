//
//  GeneralSettingsViewController.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import Cocoa
import Preferences

let GeneralSettingsViewController: () -> PreferencePane = {
    let paneView = Preferences.Pane(
        identifier: .general,
        title: "settings_tabs_general".localized(),
        toolbarIcon: NSImage(systemSymbolName: "gearshape", accessibilityDescription: "")!
    ) {
        GeneralSettingsView()
    }
    
    return Preferences.PaneHostingController(pane: paneView)
}
