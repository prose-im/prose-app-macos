//
//  MessageStore.swift
//  Prose
//
//  Created by Rémi Bardon on 26/02/2022.
//  Copyright © 2022 Prose. All rights reserved.
//

import Foundation
import OrderedCollections
import SharedModels

/// Just a temporary `struct` that will be replaced by a real implementation later.
public struct Message {
    public let senderId: String
    public let content: String
    public let timestamp: Date
}

/// This is just a simple store sendiong fake data.
/// It should not go into production, it's intended to dynamise the (currently static) app.
public final class MessageStore {
    public static let shared = MessageStore()

    private lazy var messages: [ChatID: [Message]] = [
        .person(id: "id-valerian"): (1...21).map {
            Message(
                senderId: "id-valerian",
                content: "Hello from Valerian \($0)!",
                timestamp: .now - Double($0) * 1_000
            )
        }.reversed(),
        .person(id: "id-alexandre"): (1...10).map {
            Message(
                senderId: "id-alexandre",
                content: "Hello from Alexandre \($0) 👋",
                timestamp: .now - Double($0) * 1_000
            )
        }.reversed(),
        .person(id: "id-antoine"): (1...21)
            .map { (n: Int) -> (Int, String) in
                (n, (["A"] + Array(repeating: "long", count: (n - 1) * 4) + ["message."])
                    .joined(separator: " "))
            }
            .map {
                Message(
                    senderId: "id-antoine",
                    content: $0.1,
                    timestamp: .now - Double($0.0) * 10_000
                )
            }
            .reversed(),
    ]

    private init() {}

    public func messages(for chatId: ChatID) -> [Message]? {
        self.messages[chatId]
    }

    public func unreadMessages() -> OrderedDictionary<ChatID, [Message]> {
        OrderedDictionary(dictionaryLiteral:
            (ChatID.person(id: "id-valerian"), [
                Message(
                    senderId: "id-baptiste",
                    content: "They forgot to ship the package.",
                    timestamp: Date() - 2_800
                ),
                Message(
                    senderId: "id-valerian",
                    content: "Okay, I see. Thanks. I will contact them whenever they get back online. 🤯",
                    timestamp: Date() - 3_000
                ),
            ]),
            (ChatID.person(id: "id-julien"), [
                Message(
                    senderId: "id-baptiste",
                    content: "Can I initiate a deployment of the Vue app?",
                    timestamp: Date() - 9_000
                ),
                Message(
                    senderId: "id-julien",
                    content: "Yes, it's ready. 3 new features are shipping! 😀",
                    timestamp: Date() - 10_000
                ),
            ]),
            (ChatID.group(id: "constellation"), [
                Message(
                    senderId: "id-baptiste",
                    content: "⚠️ I'm performing a change of the server IP definitions. Slight outage espected.",
                    timestamp: Date() - 90_000
                ),
                Message(
                    senderId: "id-constellation-health",
                    content: "🆘 socket-1.sgp.atlas.net.crisp.chat - Got HTTP status: \"503 or invalid body\"",
                    timestamp: Date() - 100_000
                ),
            ]))
    }
}
