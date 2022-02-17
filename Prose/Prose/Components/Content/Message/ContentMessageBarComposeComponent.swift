//
//  ContentMessageBarComposeComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/24/21.
//

import SwiftUI

struct ContentMessageBarComposeComponent: View {
    @State var firstName: String
    
    var body: some View {
        Text("content_message_bar_compose_typing".localized(withFormat: firstName))
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

struct ContentMessageBarComposeComponent_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentMessageBarComposeComponent(
                firstName: "Valerian"
            )
                .padding()
                .previewDisplayName("Simple username")
            ContentMessageBarComposeComponent(
                firstName: "Valerian"
            )
                .padding()
                .background(Color.pink)
                .previewDisplayName("Colorful background")
        }
        .preferredColorScheme(.light)
        Group {
            ContentMessageBarComposeComponent(
                firstName: "Valerian"
            )
                .padding()
                .previewDisplayName("Simple username / Dark")
            ContentMessageBarComposeComponent(
                firstName: "Valerian"
            )
                .padding()
                .background(Color.pink)
                .previewDisplayName("Colorful background / Dark")
        }
            .preferredColorScheme(.dark)
    }
}
