//
//  UnreadScreen.swift
//  Prose
//
//  Created by Rémi Bardon on 27/03/2022.
//

import ConversationFeature
import OrderedCollections
import PreviewAssets
import ProseUI
import SharedModels
import SwiftUI

public struct UnreadScreenModel: Equatable {
    let messages: OrderedDictionary<ChatID, [MessageViewModel]>

    public init(messages: OrderedDictionary<ChatID, [MessageViewModel]> = .init()) {
        self.messages = messages
    }

    func scope(for chatId: ChatID) -> UnreadSectionModel {
        UnreadSectionModel(
            chatId: chatId,
            messages: self.messages[chatId]!
        )
    }
}

public struct UnreadScreen: View {
    public let model: UnreadScreenModel

    public init(model: UnreadScreenModel) {
        self.model = model
    }

    public var body: some View {
        content()
            .background(Color.backgroundMessage)
            .toolbar(content: Toolbar.init)
    }

    @ViewBuilder
    private func content() -> some View {
        if self.model.messages.isEmpty {
            self.nothing()
        } else {
            self.list()
        }
    }

    @ViewBuilder
    private func nothing() -> some View {
        Text("Looks like you read everything 🎉")
            .font(.largeTitle.bold())
            .foregroundColor(.secondary)
            .padding()
    }

    @ViewBuilder
    private func list() -> some View {
        ScrollView {
            VStack(spacing: 24) {
                ForEach(model.messages.keys, id: \.self) { chatId in
                    UnreadSection(model: model.scope(for: chatId))
                }
            }
            .padding(24)
        }
    }
}

struct UnreadScreen_Previews: PreviewProvider {
    private struct Preview: View {
        var body: some View {
            UnreadScreen(model: .init(messages: OrderedDictionary(dictionaryLiteral:
                (ChatID.person(id: "valerian@crisp.chat"), [
                    MessageViewModel(
                        senderId: "baptiste@crisp.chat",
                        senderName: "Baptiste",
                        avatar: PreviewImages.Avatars.baptiste.rawValue,
                        content: "They forgot to ship the package.",
                        timestamp: Date() - 2_800
                    ),
                    MessageViewModel(
                        senderId: "valerian@crisp.chat",
                        senderName: "Valerian",
                        avatar: PreviewImages.Avatars.valerian.rawValue,
                        content: "Okay, I see. Thanks. I will contact them whenever they get back online. 🤯",
                        timestamp: Date() - 3_000
                    ),
                ]),
                (ChatID.person(id: "julien@thefamily.com"), [
                    MessageViewModel(
                        senderId: "baptiste@crisp.chat",
                        senderName: "Baptiste",
                        avatar: PreviewImages.Avatars.baptiste.rawValue,
                        content: "Can I initiate a deployment of the Vue app?",
                        timestamp: Date() - 9_000
                    ),
                    MessageViewModel(
                        senderId: "julien@thefamily.com",
                        senderName: "Julien",
                        avatar: PreviewImages.Avatars.julien.rawValue,
                        content: "Yes, it's ready. 3 new features are shipping! 😀",
                        timestamp: Date() - 10_000
                    ),
                ]),
                (ChatID.group(id: "constellation"), [
                    MessageViewModel(
                        senderId: "baptiste@crisp.chat",
                        senderName: "Baptiste",
                        avatar: PreviewImages.Avatars.baptiste.rawValue,
                        content: "⚠️ I'm performing a change of the server IP definitions. Slight outage espected.",
                        timestamp: Date() - 90_000
                    ),
                    MessageViewModel(
                        senderId: "constellation-health@crisp.chat",
                        senderName: "constellation-health",
                        avatar: PreviewImages.Avatars.constellationHealth.rawValue,
                        content: "🆘 socket-1.sgp.atlas.net.crisp.chat - Got HTTP status: \"503 or invalid body\"",
                        timestamp: Date() - 100_000
                    ),
                ]))))
            UnreadScreen(model: .init(messages: .init()))
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
