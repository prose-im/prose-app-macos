//
//  MessageMessengerView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import SwiftUI

struct MessageMessengerView: View {
    @State var messages = (1...21).map { "Hello \($0)" }
    
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
