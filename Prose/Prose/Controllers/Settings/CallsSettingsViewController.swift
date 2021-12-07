//
//  CallsSettingsViewController.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import Cocoa
import Preferences

let CallsSettingsViewController: () -> PreferencePane = {
    let paneView = Preferences.Pane(
        identifier: .calls,
        title: "settings_tabs_calls".localized(),
        toolbarIcon: NSImage(systemSymbolName: "phone.arrow.up.right", accessibilityDescription: "")!
    ) {
        CallsSettingsView()
    }
    
    return Preferences.PaneHostingController(pane: paneView)
}
