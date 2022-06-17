//
//  FooterDetails.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import AppLocalization
import Assets
import SwiftUI

struct FooterDetails: View {
    let teamName: String
    let statusIcon: Character
    let statusMessage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(teamName)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Asset.Color.Text.primary.swiftUIColor)

            Text("\(String(statusIcon)) “\(statusMessage)”")
                .font(.system(size: 11))
                .foregroundColor(Asset.Color.Text.secondary.swiftUIColor)
                .layoutPriority(1)
        }
        // Make hit box full width
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape([.interaction, .focusEffect], Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(L10n.Server.ConnectedTo.label(teamName)), \(statusMessage)")
    }
}

struct FooterDetails_Previews: PreviewProvider {
    private struct Preview: View {
        var body: some View {
            FooterDetails(
                teamName: "Crisp",
                statusIcon: "🚀",
                statusMessage: "Building new stuff."
            )
            .frame(maxWidth: 256)
            .padding()
            .previewLayout(.sizeThatFits)
        }
    }

    static var previews: some View {
        Preview()
            .preferredColorScheme(.light)
            .previewDisplayName("Light")
        Preview()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark")
        Preview()
            .redacted(reason: .placeholder)
            .previewDisplayName("Placeholder")
    }
}
