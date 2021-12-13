//
//  ContentMessageBarFieldComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/24/21.
//

import SwiftUI

struct ContentMessageBarFieldComponent: View {
    @State var firstName: String
    @State var message: String
    
    var body: some View {
        HStack(spacing: 0) {
            TextField(
                "content_message_bar_field_placeholder".localized(withFormat: firstName),
                text: $message
            )
                .padding([.top, .bottom], 7.0)
                .padding(.leading, 16.0)
                .padding(.trailing, 4.0)
                .font(Font.system(size: 13, weight: .regular))
                .foregroundColor(.black)
                .textFieldStyle(PlainTextFieldStyle())
            
            Button(action: {}) {
                Image(systemName: "paperplane.circle.fill")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(.buttonPrimary)
            }
                .buttonStyle(PlainButtonStyle())
                .offset(x: -3, y: 0)
        }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.borderSecondary, lineWidth: 1)
            )
    }
}

struct ContentMessageBarFieldComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentMessageBarFieldComponent(
            firstName: "Valerian",
            message: "This is a message that was written."
        )
    }
}
