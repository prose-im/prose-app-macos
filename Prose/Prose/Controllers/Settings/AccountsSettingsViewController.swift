//
//  AccountsSettingsViewController.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import Cocoa
import Preferences

let AccountsSettingsViewController: () -> PreferencePane = {
    let paneView = Preferences.Pane(
        identifier: .accounts,
        title: "settings_tabs_accounts".localized(),
        toolbarIcon: NSImage(systemSymbolName: "person.2", accessibilityDescription: "")!
    ) {
        AccountsSettingsView()
    }
    
    return Preferences.PaneHostingController(pane: paneView)
}
