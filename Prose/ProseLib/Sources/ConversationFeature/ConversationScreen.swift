//
//  ConversationScreen.swift
//  Prose
//
//  Created by Valerian Saliou on 11/21/21.
//

import SharedModels
import SwiftUI

public struct ConversationScreen: View {
    let chatId: ChatID
    let sender: User
    let chatViewModel: ChatViewModel

    public init(chatId: ChatID) {
        self.chatId = chatId
        switch chatId {
        case let .person(userId):
            self.sender = UserStore.shared.user(for: userId) ?? .init(userId: "", displayName: "", fullName: "", avatar: "")
        case .group:
            fatalError("Not supported yet")
        }
        let messages = (MessageStore.shared.messages(for: chatId) ?? [])
            .map(\.toMessageViewModel)
        self.chatViewModel = .init(messages: messages)
    }

    public var body: some View {
        HStack(spacing: 0) {
            ChatWithMessageBar(chatViewModel: chatViewModel)

            Divider()

            ConversationDetailsView(
                avatar: sender.avatar,
                name: sender.displayName
            )
            .frame(width: 220.0)
        }
    }
}

struct ConversationScreen_Previews: PreviewProvider {
    static var previews: some View {
        ConversationScreen(chatId: .person(id: "id-alexandre"))
    }
}
