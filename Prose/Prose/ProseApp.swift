//
//  ProseApp.swift
//  Prose
//
//  Created by Valerian Saliou on 9/14/21.
//

import SwiftUI
import Preferences

@main
struct ProseApp: App {
    var body: some Scene {
        WindowGroup {
            BaseView()
        }
        .windowStyle(DefaultWindowStyle())
        .windowToolbarStyle(UnifiedWindowToolbarStyle())
        .commands {
            SidebarCommands()
            
            CommandMenu("TODO Menu") {
                Button("Say Hello") {
                    print("Hello!")
                }
                .keyboardShortcut("h")
            }
            
            CommandGroup(replacing: CommandGroupPlacement.appSettings) {
                Button("Preferences...") {
                    PreferencesWindowController(
                        preferencePanes: [
                            GeneralSettingsViewController(),
                            AccountsSettingsViewController(),
                            NotificationsSettingsViewController(),
                            MessagesSettingsViewController(),
                            CallsSettingsViewController(),
                            AdvancedSettingsViewController()
                        ],
                        
                        style: .toolbarItems,
                        animated: true,
                        hidesToolbarForSingleItem: true
                    ).show()
                }.keyboardShortcut(KeyEquivalent(","), modifiers: .command)
            }
        }
    }
}
