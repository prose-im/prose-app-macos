//
//  ActionRow.swift
//  Prose
//
//  Created by Valerian Saliou on 12/1/21.
//

import Assets
import SwiftUI

struct ActionRow: View {
    let name: String
    var deployTo: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack(spacing: 8) {
                Text(self.name)
                    .fontWeight(.medium)

                Spacer()

                if self.deployTo {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10))
                        .foregroundColor(Colors.Text.primary.color)
                }
            }
            // Make hit box full width
            .contentShape([.interaction], Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct ActionRow_Previews: PreviewProvider {
    static var previews: some View {
        ActionRow(
            name: "View full profile",
            deployTo: true,
            action: {}
        )
    }
}
