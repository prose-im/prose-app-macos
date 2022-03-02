//
//  MessageView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/21/21.
//

import SwiftUI

struct MessageView: View {
    let chatId: String
    let sender: User
    let messages: [MessageViewModel]
    
    init(chatId: String) {
        self.chatId = chatId
        self.sender = UserStore.shared.user(for: chatId) ?? .init(userId: "", displayName: "", avatar: "")
        self.messages = (MessageStore.shared.messages(for: chatId) ?? [])
            .map(\.toMessageViewModel)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            MessageMessengerView(messages: messages)
            
            Divider()
            
            MessageDetailsView(
                avatar: sender.avatar,
                name: sender.displayName
            )
                .frame(width: 220.0)
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(chatId: "id-alexandre")
    }
}
