//
//  Chat.swift
//  Prose
//
//  Created by Rémi Bardon on 03/03/2022.
//  Copyright © 2022 Prose. All rights reserved.
//

import OrderedCollections
import SwiftUI

struct ChatViewModel {
    
    let messages: OrderedDictionary<Date, [MessageViewModel]>
    
    init(messages: OrderedDictionary<Date, [MessageViewModel]>) {
        self.messages = messages
    }
    
    init(messages: [Date: [MessageViewModel]]) {
        self.init(messages: OrderedDictionary(uniqueKeys: messages.keys, values: messages.values))
    }
    
    init(messages: [MessageViewModel]) {
        let calendar = Calendar.current
        self.init(messages: OrderedDictionary(grouping: messages, by: { calendar.startOfDay(for: $0.timestamp) }))
    }
    
}

struct Chat: View {
    let model: ChatViewModel
    
    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(model.messages.keys, id: \.self) { date in
                        Section {
                            ForEach(model.messages[date]!, content: MessageView.init(model:))
                        } header: {
                            DaySeparator(date: date)
                                .padding(.top)
                        }
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            .onAppear {
                if let id = model.messages.values.last?.last?.id {
                    scrollView.scrollTo(id, anchor: .top)
                }
            }
        }
        .background(Color.backgroundMessage)
    }
}

struct Chat_Previews: PreviewProvider {
    static let messages: [MessageViewModel] = (1...21)
        .map { (n: Int) -> (Int, String) in
            (n, (["A"] + Array(repeating: "long", count: (n - 1) * 4) + ["message."])
                .joined(separator: " "))
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
        Chat(model: .init(messages: Self.messages))
    }
}
