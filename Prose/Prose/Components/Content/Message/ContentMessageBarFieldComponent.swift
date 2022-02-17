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
                .padding(.vertical, 7.0)
                .padding(.leading, 16.0)
                .padding(.trailing, 4.0)
                .font(Font.system(size: 13, weight: .regular))
                .foregroundColor(.primary)
                .textFieldStyle(.plain)
            
            Button(action: {}) {
                Image(systemName: "paperplane.circle.fill")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(.buttonPrimary)
                    .padding(3)
            }
            .buttonStyle(.plain)
        }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.background)
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.borderSecondary)
                }
            )
    }
}

struct ContentMessageBarFieldComponent_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentMessageBarFieldComponent(
                firstName: "Valerian",
                message: "This is a message that was written."
            )
                .previewDisplayName("Simple message")
            ContentMessageBarFieldComponent(
                firstName: "Valerian",
                message: "This is a \(Array(repeating: "very", count: 20).joined(separator: " ")) long message that was written."
            )
                .previewDisplayName("Long message")
            ContentMessageBarFieldComponent(
                firstName: "Very \(Array(repeating: "very", count: 20).joined(separator: " ")) long username",
                message: ""
            )
                .previewDisplayName("Long username")
            ContentMessageBarFieldComponent(
                firstName: "Valerian",
                message: ""
            )
                .previewDisplayName("Empty")
            ContentMessageBarFieldComponent(
                firstName: "Valerian",
                message: ""
            )
                .padding()
                .background(Color.pink)
                .previewDisplayName("Colorful background")
        }
            .preferredColorScheme(.light)
        Group {
            ContentMessageBarFieldComponent(
                firstName: "Valerian",
                message: "This is a message that was written."
            )
                .previewDisplayName("Simple message / Dark")
            ContentMessageBarFieldComponent(
                firstName: "Valerian",
                message: ""
            )
                .previewDisplayName("Empty / Dark")
            ContentMessageBarFieldComponent(
                firstName: "Valerian",
                message: ""
            )
                .padding()
                .background(Color.pink)
                .previewDisplayName("Colorful background / Dark")
        }
            .preferredColorScheme(.dark)
    }
}
