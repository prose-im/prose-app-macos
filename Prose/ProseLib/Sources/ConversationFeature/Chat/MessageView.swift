//
//  MessageView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/21/21.
//

import PreviewAssets
import ProseCoreStub
import ProseUI
import SharedModels
import SwiftUI

public struct MessageView: View {
    let model: MessageViewModel

    public init(model: MessageViewModel) {
        self.model = model
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Avatar(model.avatar, size: 32)

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline) {
                    Text(model.senderName)
                        .font(.system(size: 13).bold())
                        .foregroundColor(.textPrimary)

                    Text(model.timestamp, format: .relative(presentation: .numeric))
                        .font(.system(size: 11.5))
                        .foregroundColor(.textSecondary)
                }

                Text(model.content)
                    .font(.system(size: 12.5))
                    .fontWeight(.regular)
                    .foregroundColor(.textPrimary)
            }
            .textSelection(.enabled)

            Spacer()
        }
    }
}

public struct MessageViewModel: Equatable {
    let senderId: JID
    let senderName: String
    let avatar: String
    let content: String
    public let timestamp: Date

    public init(
        senderId: JID,
        senderName: String,
        avatar: String,
        content: String,
        timestamp: Date
    ) {
        self.senderId = senderId
        self.senderName = senderName
        self.avatar = avatar
        self.content = content
        self.timestamp = timestamp
    }
}

extension MessageViewModel: Identifiable {
    public var id: String { "\(self.senderId)_\(self.timestamp.ISO8601Format())" }
}

public extension Message {
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

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MessageView(model: .init(
                senderId: "valerian@crisp.chat",
                senderName: "Valerian",
                avatar: PreviewImages.Avatars.valerian.rawValue,
                content: "Hello world, this is a message content!",
                timestamp: .now - 10_000
            ))
            MessageView(model: .init(
                senderId: "valerian@crisp.chat",
                senderName: "Valerian",
                avatar: PreviewImages.Avatars.valerian.rawValue,
                content: Array(repeating: "Hello world, this is a message content!", count: 5).joined(separator: " "),
                timestamp: .now - 1_000
            ))
            .frame(width: 500)
            MessageView(model: .init(
                senderId: "unknown@prose.org",
                senderName: "Unknown",
                avatar: "",
                content: "Unknown",
                timestamp: .now - 500
            ))
            .preferredColorScheme(.light)
            MessageView(model: .init(
                senderId: "unknown@prose.org",
                senderName: "Unknown",
                avatar: "",
                content: "Unknown",
                timestamp: .now - 50
            ))
            .preferredColorScheme(.dark)
        }
//            .border(Color.green)
        .padding()
    }
}
