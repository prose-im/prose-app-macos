//
//  ProseApp.swift
//  Prose
//
//  Created by Valerian Saliou on 9/14/21.
//

import App
import SwiftUI
import SettingsFeature

@main
struct ProseApp: App {
    var body: some Scene {
        WindowGroup {
            AppView()
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
            
            AppSettings()
        }
    }
}
