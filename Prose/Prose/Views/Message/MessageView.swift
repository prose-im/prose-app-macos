//
//  MessageView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/21/21.
//

import SwiftUI

struct MessageView: View {
    let chatId: String
    let messages: [MessageViewModel]
    
    init(chatId: String) {
        self.chatId = chatId
        self.messages = (MessageStore.shared.messages(for: chatId) ?? [])
            .map(\.toMessageViewModel)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            MessageMessengerView(messages: messages)
            
            Divider()
            
            MessageDetailsView(
                avatar: "avatar-valerian",
                name: "Valerian Saliou"
            )
                .frame(width: 220.0)
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(chatId: "id-julian")
    }
}
