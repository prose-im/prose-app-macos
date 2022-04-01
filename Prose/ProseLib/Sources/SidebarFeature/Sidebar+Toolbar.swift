//
//  Sidebar+Toolbar.swift
//  Prose
//
//  Created by Valerian Saliou on 12/12/21.
//

import SwiftUI

struct SidebarToolbar: ToolbarContent {
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button(action: {}) {
                Label("Phone", systemImage: "phone.bubble.left")
            }
            
            Button(action: {}) {
                Label("Edit", systemImage: "square.and.pencil")
            }
        }
    }
    
}
