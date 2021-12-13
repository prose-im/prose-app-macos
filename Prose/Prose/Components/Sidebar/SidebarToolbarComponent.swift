//
//  SidebarToolbarComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 12/12/21.
//

import SwiftUI

struct SidebarToolbarComponent: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            HStack(spacing: 0) {
                Button(action: {}) {
                    Image(systemName: "phone.bubble.left")
                }
                
                Button(action: {}) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
    }
}
