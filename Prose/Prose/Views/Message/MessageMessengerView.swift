//
//  MessageMessengerView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import SwiftUI

struct MessageMessengerView: View {
    @State var messages = [
        "Hello 1",
        "Hello 2",
        "Hello 3",
        "Hello 4",
        "Hello 5",
        "Hello 6",
        "Hello 7",
        "Hello 8",
        "Hello 9",
        "Hello 10",
        "Hello 11"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(messages, id: \.self) { message in
                        ContentMessageBubbleComponent(text: message)
                    }
                }
                .padding()
            }
            
            ContentMessageBarComponent(
                firstName: "Valerian"
            )
        }
    }
}

struct MessageMessengerView_Previews: PreviewProvider {
    static var previews: some View {
        MessageMessengerView()
    }
}
