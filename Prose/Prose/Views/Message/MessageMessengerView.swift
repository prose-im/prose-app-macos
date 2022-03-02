//
//  MessageMessengerView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import SwiftUI
import OrderedCollections

struct MessageMessengerView: View {
    @State var messages: OrderedDictionary<Date, [MessageViewModel]>
    
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
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(messages.keys, id: \.self) { date in
                            Section {
                                ForEach(messages[date]!, content: ContentMessageBubbleComponent.init(model:))
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
                    if let id = messages.values.last?.last?.id {
                        scrollView.scrollTo(id, anchor: .top)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.backgroundMessage)
            
            ContentMessageBarComponent(
                firstName: "Valerian"
            )
                .layoutPriority(1)
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
                avatar: PreviewImages.Avatars.valerian.rawValue,
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
