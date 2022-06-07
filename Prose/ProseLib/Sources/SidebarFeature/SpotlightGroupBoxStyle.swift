//
//  SpotlightGroupBoxStyle.swift
//  Prose
//
//  Created by Rémi Bardon on 27/03/2022.
//

import SharedModels
import SwiftUI

struct SpotlightGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 12) {
            configuration.label
                .padding(.horizontal, 4)
            VStack(spacing: 6) {
                configuration.content
                    .modifier(SpotlightItemBackground())
            }
        }
    }
}

extension GroupBoxStyle where Self == SpotlightGroupBoxStyle {
    static var spotlight: Self { SpotlightGroupBoxStyle() }
}

#if DEBUG
    import ConversationFeature
    import PreviewAssets
#endif

struct SpotlightGroupBoxStyle_Previews: PreviewProvider {
    static var previews: some View {
        GroupBox {
            MessageView(model: .init(
                senderId: "valerian@crisp.chat",
                senderName: "Valerian",
                avatar: PreviewImages.Avatars.valerian.rawValue,
                content: "Message from Valerian",
                timestamp: Date() - 10_000
            ))
            MessageView(model: .init(
                senderId: "baptiste@crisp.chat",
                senderName: "Baptiste",
                avatar: PreviewImages.Avatars.baptiste.rawValue,
                content: "Message from Baptiste",
                timestamp: Date() - 15_000
            ))
        } label: {
            HStack {
                Label("support", systemImage: Icon.group.rawValue)
                    .labelStyle(.coloredIcon)
                    .font(.title2.bold())
                Spacer()
                Text("dummy")
                    .foregroundColor(.secondary)
            }
        }
        .groupBoxStyle(.spotlight)
    }
}
