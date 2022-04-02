//
//  SidebarActionRow.swift
//  Prose
//
//  Created by Rémi Bardon on 26/02/2022.
//  Copyright © 2022 Prose. All rights reserved.
//

import SwiftUI

struct SidebarActionRow: View {
    
    let title: LocalizedStringKey
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .symbolVariant(.fill)
                // Make hit box full width
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.interaction, Rectangle())
        }
        .buttonStyle(.plain)
    }
    
}

struct SidebarActionRow_Previews: PreviewProvider {
    
    static var previews: some View {
        SidebarActionRow(
            title: "sidebar_groups_add",
            systemImage: "plus.square",
            action: {}
        )
        .frame(width: 196)
    }
    
}
