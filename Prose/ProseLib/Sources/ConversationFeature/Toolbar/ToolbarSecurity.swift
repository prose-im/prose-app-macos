//
//  ToolbarSecurity.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SharedModels
import SwiftUI

/// Separated as its own view as we might need to reuse it someday.
struct ToolbarSecurity: View {
    let jid: JID
    let isVerified: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            if isVerified {
                Image(systemName: "checkmark.seal.fill")
                    .renderingMode(.template)
                    .foregroundColor(.stateGreen)
                    .accessibilityElement()
                    .accessibilityLabel("Verified")
                    .accessibilitySortPriority(1)
            }

            Text(verbatim: String(describing: jid))
                .foregroundColor(.textSecondary)
                .accessibilitySortPriority(2)
        }
        .padding(.horizontal, 8)
        .accessibilityElement(children: .combine)
    }
}

struct ToolbarSecurity_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ToolbarSecurity(
                jid: "valerian@prose.org",
                isVerified: true
            )
            ToolbarSecurity(
                jid: "valerian@prose.org",
                isVerified: false
            )
        }
    }
}
