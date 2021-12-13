//
//  ContentMessageBubbleComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/21/21.
//

import SwiftUI

struct ContentMessageBubbleComponent: View {
    @State var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.square.fill")
                .foregroundColor(Color.blue)
                .opacity(0.5)
                .font(.system(size: 32))
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline) {
                    Text("John Doe")
                        .font(.system(size: 13).bold())
                        .foregroundColor(.textPrimary)
                    
                    Text("0:00 PM")
                        .font(.system(size: 11.5))
                        .foregroundColor(.textSecondary)
                }
                
                Text(text)
                    .font(.system(size: 12.5))
                    .fontWeight(.regular)
                    .foregroundColor(.textPrimary)
            }
            .offset(x: -3, y: 0)
            
            Spacer()
        }
    }
}

struct ContentMessageBubbleComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentMessageBubbleComponent(
            text: "Hello world, this is a message content!"
        )
    }
}
