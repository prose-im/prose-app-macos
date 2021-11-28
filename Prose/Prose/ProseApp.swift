//
//  ProseApp.swift
//  Prose
//
//  Created by Valerian Saliou on 9/14/21.
//

import SwiftUI

@main
struct ProseApp: App {
    var body: some Scene {
        WindowGroup {
            BaseView()
        }
        .windowStyle(DefaultWindowStyle())
        .windowToolbarStyle(UnifiedWindowToolbarStyle())
        .commands {
            CommandMenu("TODO Menu") {
                Button("Say Hello") {
                    print("Hello!")
                }
                .keyboardShortcut("h")
            }
        }
    }
}
