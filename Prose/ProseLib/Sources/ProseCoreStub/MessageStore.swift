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
    public let senderId: JID
    public let content: String
    public let timestamp: Date
}

/// This is just a simple store sending fake data.
/// It should not go into production, it's intended to dynamise the (currently static) app.
public final class MessageStore {
    public static let shared = MessageStore()

    private lazy var messages: [ChatID: [Message]] = [
        .person(id: "valerian@crisp.chat"): (1...21).map {
            Message(
                senderId: "valerian@crisp.chat",
                content: "Hello from Valerian \($0)!",
                timestamp: .now - Double($0) * 1_000
            )
        }.reversed(),
        .person(id: "alexandre@crisp.chat"): (1...10).map {
            Message(
                senderId: "alexandre@crisp.chat",
                content: "Hello from Alexandre \($0) 👋",
                timestamp: .now - Double($0) * 1_000
            )
        }.reversed(),
        .person(id: "antoine@crisp.chat"): (1...21)
            .map { (n: Int) -> (Int, String) in
                (n, (["A"] + Array(repeating: "long", count: (n - 1) * 4) + ["message."])
                    .joined(separator: " "))
            }
            .map {
                Message(
                    senderId: "antoine@crisp.chat",
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
            (ChatID.person(id: "valerian@crisp.chat"), [
                Message(
                    senderId: "baptiste@crisp.chat",
                    content: "They forgot to ship the package.",
                    timestamp: Date() - 2_800
                ),
                Message(
                    senderId: "valerian@crisp.chat",
                    content: "Okay, I see. Thanks. I will contact them whenever they get back online. 🤯",
                    timestamp: Date() - 3_000
                ),
            ]),
            (ChatID.person(id: "julien@thefamily.com"), [
                Message(
                    senderId: "baptiste@crisp.chat",
                    content: "Can I initiate a deployment of the Vue app?",
                    timestamp: Date() - 9_000
                ),
                Message(
                    senderId: "julien@thefamily.com",
                    content: "Yes, it's ready. 3 new features are shipping! 😀",
                    timestamp: Date() - 10_000
                ),
            ]),
            (ChatID.group(id: "constellation"), [
                Message(
                    senderId: "baptiste@crisp.chat",
                    content: "⚠️ I'm performing a change of the server IP definitions. Slight outage espected.",
                    timestamp: Date() - 90_000
                ),
                Message(
                    senderId: "constellation-health@crisp.chat",
                    content: "🆘 socket-1.sgp.atlas.net.crisp.chat - Got HTTP status: \"503 or invalid body\"",
                    timestamp: Date() - 100_000
                ),
            ]))
    }
}
