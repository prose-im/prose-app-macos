//
//  SidebarFooterDetails.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct SidebarFooterDetails: View {
    let teamName: String
    let statusIcon: Character
    let statusMessage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(teamName)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.textPrimary)

            Text("\(String(statusIcon)) “\(statusMessage)”")
                .font(.system(size: 11))
                .foregroundColor(.textSecondary)
                .layoutPriority(1)
        }
    }
}

struct SidebarFooterDetails_Previews: PreviewProvider {
    private struct Preview: View {
        var body: some View {
            SidebarFooterDetails(
                teamName: "Crisp",
                statusIcon: "🚀",
                statusMessage: "Building new stuff."
            )
        }
    }

    static var previews: some View {
        Preview()
            .preferredColorScheme(.light)
            .previewDisplayName("Light")

        Preview()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark")
    }
}
