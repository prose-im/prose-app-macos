//
//  SpotlightGroupBoxStyle.swift
//  Prose
//
//  Created by Rémi Bardon on 27/03/2022.
//

import SharedModels
import SwiftUI

extension GroupBoxStyle where Self == SpotlightGroupBoxStyle {
    static var spotlight: Self { SpotlightGroupBoxStyle() }
}

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

private struct SpotlightItemBackground: ViewModifier {
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

    struct SpotlightGroupBoxStyle_Previews: PreviewProvider {
        static var previews: some View {
            GroupBox {
                MessageView(model: .init(
                    senderId: "valerian@crisp.chat",
                    senderName: "Valerian",
                    avatarURL: PreviewAsset.Avatars.valerian.customURL,
                    content: "Message from Valerian",
                    timestamp: Date() - 10_000
                ))
                MessageView(model: .init(
                    senderId: "baptiste@crisp.chat",
                    senderName: "Baptiste",
                    avatarURL: PreviewAsset.Avatars.baptiste.customURL,
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

    struct SpotlightItemBackground_Previews: PreviewProvider {
        static var previews: some View {
            MessageView(model: .init(
                senderId: "valerian@crisp.chat",
                senderName: "Valerian",
                avatarURL: PreviewAsset.Avatars.valerian.customURL,
                content: "Message from Valerian",
                timestamp: Date() - 10_000
            ))
            .modifier(SpotlightItemBackground())
            .padding()
        }
    }
#endif
