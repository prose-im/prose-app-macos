//
//  ActionRow.swift
//  Prose
//
//  Created by Rémi Bardon on 26/02/2022.
//  Copyright © 2022 Prose. All rights reserved.
//

import SwiftUI

struct ActionButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: "plus.square.fill")
                .symbolVariant(.fill)
                // Make hit box full width
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.interaction, Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct ActionRow_Previews: PreviewProvider {
    static var previews: some View {
        ActionButton(
            title: "sidebar_groups_add",
            action: {}
        )
        .frame(width: 196)
    }
}
