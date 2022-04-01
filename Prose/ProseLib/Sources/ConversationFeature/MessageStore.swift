//
//  MessageStore.swift
//  Prose
//
//  Created by Rémi Bardon on 26/02/2022.
//  Copyright © 2022 Prose. All rights reserved.
//

import Foundation

/// Just a temporary `struct` that will be replaced by a real implementation later.
struct Message {
    let senderId: String
    let content: String
    let timestamp: Date
}

/// This is just a simple store sendiong fake data.
/// It should not go into production, it's intended to dynamise the (currently static) app.
final class MessageStore {
    static let shared = MessageStore()
    
    private lazy var messages: [String: [Message]] = [
        "id-valerian": (1...21).map {
            Message(
                senderId: "id-valerian",
                content: "Hello from Valerian \($0)!",
                timestamp: .now - Double($0) * 1_000
            )
        }.reversed(),
        "id-alexandre": (1...10).map {
            Message(
                senderId: "id-alexandre",
                content: "Hello from Alexandre \($0) 👋",
                timestamp: .now - Double($0) * 1_000
            )
        }.reversed(),
        "id-antoine": (1...21)
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
    
    func messages(for chatId: String) -> [Message]? {
        messages[chatId]
    }
}

extension Message {
    var toMessageViewModel: MessageViewModel {
        let sender = UserStore.shared.user(for: self.senderId)
        
        return MessageViewModel(
            senderId: self.senderId,
            senderName: sender?.displayName ?? "Unknown",
            avatar: sender?.avatar ?? "",
            content: self.content,
            timestamp: self.timestamp
        )
    }
}
