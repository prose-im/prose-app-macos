//
//  ChatWithBar.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import OrderedCollections
import PreviewAssets
import SwiftUI

struct ChatWithMessageBar: View {
    let chatViewModel: ChatViewModel

    var body: some View {
        Chat(model: chatViewModel)
            .frame(maxWidth: .infinity)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                MessageBar(
                    firstName: "Valerian"
                )
                // Make footer have a higher priority, to be accessible over the scroll view
                .accessibilitySortPriority(1)
            }
    }
}

struct ChatWithMessageBar_Previews: PreviewProvider {
    static let messages: [MessageViewModel] = (1...21)
        .map { (n: Int) -> (Int, String) in
            (n, "Message \(n)")
        }
        .map {
            MessageViewModel(
                senderId: "id-valerian",
                senderName: "Valerian",
                avatar: PreviewImages.Avatars.valerian.rawValue,
                content: $0.1,
                timestamp: .now - Double($0.0) * 1_000
            )
        }

    static var previews: some View {
        ChatWithMessageBar(chatViewModel: .init(messages: Self.messages))
    }
}
