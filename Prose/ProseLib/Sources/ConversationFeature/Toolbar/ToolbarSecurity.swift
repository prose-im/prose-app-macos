//
//  ToolbarSecurity.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import Assets
import ProseCoreTCA
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
                    .foregroundColor(Colors.State.green.color)
                    .accessibilityElement()
                    .accessibilityLabel("Verified")
                    .accessibilitySortPriority(1)
            }

            Text(verbatim: String(describing: jid))
                .foregroundColor(Colors.Text.secondary.color)
                .accessibilitySortPriority(2)
        }
        .padding(.horizontal, 8)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
    struct ToolbarSecurity_Previews: PreviewProvider {
        static var previews: some View {
            VStack(alignment: .leading) {
                ToolbarSecurity(
                    jid: "valerian@prose.org",
                    isVerified: true
                )
                ToolbarSecurity(
                    jid: "valerian@prose.org",
                    isVerified: false
                )
                ToolbarSecurity(
                    jid: "valerian@prose.org",
                    isVerified: false
                )
                .redacted(reason: .placeholder)
                .previewDisplayName("Placeholder")
            }
            .previewLayout(.sizeThatFits)
        }
    }
#endif
