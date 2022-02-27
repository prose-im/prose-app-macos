//
//  MessageMessengerView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import SwiftUI

struct MessageMessengerView: View {
    @State var messages: [MessageViewModel]
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(messages, content: ContentMessageBubbleComponent.init(model:))
                }
                .padding()
            }
            .background(Color.backgroundMessage)
            
            ContentMessageBarComponent(
                firstName: "Valerian"
            )
        }
    }
}

struct MessageMessengerView_Previews: PreviewProvider {
    static let messages: [MessageViewModel] = (1...21)
        .map { (n: Int) -> (Int, String) in
            (n, (["A"] + Array(repeating: "long", count: (n - 1) * 4) + ["message."])
                .joined(separator: " "))
        }
        .map {
            MessageViewModel(
                senderId: "id-valerian",
                senderName: "Valerian",
                avatar: "avatar-valerian",
                content: $0.1,
                timestamp: .now - Double($0.0) * 1_000
            )
        }
    
    static var previews: some View {
        MessageMessengerView(
            messages: Self.messages
        )
    }
}
