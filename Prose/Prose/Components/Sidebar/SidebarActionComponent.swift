//
//  SidebarActionComponent.swift
//  Prose
//
//  Created by Rémi Bardon on 26/02/2022.
//  Copyright © 2022 Prose. All rights reserved.
//

import SwiftUI

struct SidebarActionComponent: View {
    
    let title: LocalizedStringKey
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                // Make hit box full width
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.interaction, Rectangle())
        }
        .buttonStyle(.plain)
    }
    
}

struct SidebarActionComponent_Previews: PreviewProvider {
    static var previews: some View {
        SidebarActionComponent(
            title: "sidebar_groups_add",
            systemImage: "plus.square.fill",
            action: {}
        )
    }
}
