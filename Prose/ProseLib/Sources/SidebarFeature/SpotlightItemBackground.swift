//
//  SpotlightItemBackground.swift
//  Prose
//
//  Created by Rémi Bardon on 27/03/2022.
//

import SwiftUI

struct SpotlightItemBackground: ViewModifier {
    var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 3)
    }

    func body(content: Content) -> some View {
        content
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background {
                shape
                    .fill(.background)
                    .shadow(color: .gray.opacity(0.5), radius: 1)
            }
    }
}

#if DEBUG
    import ConversationFeature
    import PreviewAssets
#endif

struct SpotlightItemBackground_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(model: .init(
            senderId: "id-valerian",
            senderName: "Valerian",
            avatar: PreviewImages.Avatars.valerian.rawValue,
            content: "Message from Valerian",
            timestamp: Date() - 10_000
        ))
        .modifier(SpotlightItemBackground())
        .padding()
    }
}
