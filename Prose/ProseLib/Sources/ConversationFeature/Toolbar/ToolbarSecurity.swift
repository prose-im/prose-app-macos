//
//  ToolbarSecurity.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

/// Separated as its own view as we might need to reuse it someday.
struct ToolbarSecurity: View {
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Image(systemName: "checkmark.seal.fill")
                .renderingMode(.template)
                .foregroundColor(.stateGreen)
                .accessibilityElement()
                .accessibilityLabel("Verified")
                .accessibilitySortPriority(1)

            Text(verbatim: "valerian@crisp.chat")
                .foregroundColor(.textSecondary)
                .accessibilitySortPriority(2)
        }
        .padding(.horizontal, 8)
        .accessibilityElement(children: .combine)
    }
}

struct ToolbarSecurity_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarSecurity()
    }
}
