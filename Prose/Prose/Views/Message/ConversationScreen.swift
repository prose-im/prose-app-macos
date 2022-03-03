//
//  ConversationScreen.swift
//  Prose
//
//  Created by Valerian Saliou on 11/21/21.
//

import SwiftUI

struct ConversationScreen: View {
    let chatId: String
    let sender: User
    let chatViewModel: ChatViewModel
    
    init(chatId: String) {
        self.chatId = chatId
        self.sender = UserStore.shared.user(for: chatId) ?? .init(userId: "", displayName: "", avatar: "")
        let messages = (MessageStore.shared.messages(for: chatId) ?? [])
            .map(\.toMessageViewModel)
        self.chatViewModel = .init(messages: messages)
    }
    
    var body: some View {
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
        ConversationScreen(chatId: "id-alexandre")
    }
}
