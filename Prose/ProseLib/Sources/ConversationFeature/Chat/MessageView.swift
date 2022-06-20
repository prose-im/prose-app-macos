//
//  MessageView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/21/21.
//

import Assets
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
                        .foregroundColor(Asset.Color.Text.primary.swiftUIColor)

                    Text(model.timestamp, format: .relative(presentation: .numeric))
                        .font(.system(size: 11.5))
                        .foregroundColor(Asset.Color.Text.secondary.swiftUIColor)
                }

                Text(model.content)
                    .font(.system(size: 12.5))
                    .fontWeight(.regular)
                    .foregroundColor(Asset.Color.Text.primary.swiftUIColor)
            }
            .textSelection(.enabled)

            Spacer()
        }
    }
}

public struct MessageViewModel: Equatable {
    let senderId: JID
    let senderName: String
    let avatarURL: URL?
    let content: String
    public let timestamp: Date

    var avatar: AvatarImage { AvatarImage(url: self.avatarURL) }

    public init(
        senderId: JID,
        senderName: String,
        avatarURL: URL?,
        content: String,
        timestamp: Date
    ) {
        self.senderId = senderId
        self.senderName = senderName
        self.avatarURL = avatarURL
        self.content = content
        self.timestamp = timestamp
    }
}

extension MessageViewModel: Identifiable {
    public var id: String { "\(self.senderId)_\(self.timestamp.ISO8601Format())" }
}

public extension Message {
    func toMessageViewModel(userStore: UserStore) -> MessageViewModel {
        let sender = userStore.user(self.senderId)

        return MessageViewModel(
            senderId: self.senderId,
            senderName: sender?.displayName ?? "Unknown",
            avatarURL: sender.flatMap(\.avatar),
            content: self.content,
            timestamp: self.timestamp
        )
    }
}

#if DEBUG
    import PreviewAssets

    struct MessageView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                MessageView(model: .init(
                    senderId: "valerian@crisp.chat",
                    senderName: "Valerian",
                    avatarURL: PreviewAsset.Avatars.valerian.customURL,
                    content: "Hello world, this is a message content!",
                    timestamp: .now - 10_000
                ))
                MessageView(model: .init(
                    senderId: "valerian@crisp.chat",
                    senderName: "Valerian",
                    avatarURL: PreviewAsset.Avatars.valerian.customURL,
                    content: Array(repeating: "Hello world, this is a message content!", count: 5).joined(separator: " "),
                    timestamp: .now - 1_000
                ))
                .frame(width: 500)
                MessageView(model: .init(
                    senderId: "unknown@prose.org",
                    senderName: "Unknown",
                    avatarURL: nil,
                    content: "Unknown",
                    timestamp: .now - 500
                ))
                .preferredColorScheme(.light)
                MessageView(model: .init(
                    senderId: "unknown@prose.org",
                    senderName: "Unknown",
                    avatarURL: nil,
                    content: "Unknown",
                    timestamp: .now - 50
                ))
                .preferredColorScheme(.dark)
            }
            //            .border(Color.green)
            .padding()
        }
    }
#endif
