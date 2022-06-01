//
//  SidebarFooterActionButton.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct SidebarFooterActionButton: View {
    var body: some View {
        Button(action: {}) {
            ZStack {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.textSecondary)

                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color.secondary.opacity(0.125))
                    .frame(width: 24, height: 32)
            }
        }
        .buttonStyle(.plain)
    }
}

struct SidebarFooterActionButton_Previews: PreviewProvider {
    private struct Preview: View {
        var body: some View {
            SidebarFooterActionButton()
                .padding()
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
