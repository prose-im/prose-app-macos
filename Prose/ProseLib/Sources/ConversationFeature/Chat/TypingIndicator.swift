//
//  TypingIndicator.swift
//  Prose
//
//  Created by Valerian Saliou on 11/24/21.
//

import AppLocalization
import SwiftUI

private let l10n = L10n.Content.MessageBar.self

struct TypingIndicator: View {
    @State var firstName: String

    var body: some View {
        Text(l10n.composeTyping(firstName))
            .padding(.vertical, 4.0)
            .padding(.horizontal, 16.0)
            .font(Font.system(size: 10.5, weight: .light))
            .foregroundColor(.textSecondary)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.background)
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.borderTertiary)
                }
            )
            // TODO: [Rémi Bardon] Probably remove this, as 0.025≈0
            .shadow(color: .black.opacity(0.025), radius: 3, y: 1)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TypingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TypingIndicator(
                firstName: "Valerian"
            )
            .padding()
            .previewDisplayName("Simple username")
            TypingIndicator(
                firstName: "Valerian"
            )
            .padding()
            .background(Color.pink)
            .previewDisplayName("Colorful background")
        }
        .preferredColorScheme(.light)
        Group {
            TypingIndicator(
                firstName: "Valerian"
            )
            .padding()
            .previewDisplayName("Simple username / Dark")
            TypingIndicator(
                firstName: "Valerian"
            )
            .padding()
            .background(Color.pink)
            .previewDisplayName("Colorful background / Dark")
        }
        .preferredColorScheme(.dark)
    }
}
