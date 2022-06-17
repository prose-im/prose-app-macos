//
//  MessageBarTextField.swift
//  Prose
//
//  Created by Valerian Saliou on 11/24/21.
//

import AppLocalization
import Assets
import SwiftUI

private let l10n = L10n.Content.MessageBar.self

struct MessageBarTextField: View {
    @Environment(\.redactionReasons) private var redactionReasons

    @State var firstName: String
    @Binding var message: String

    var body: some View {
        HStack(spacing: 0) {
            TextField(l10n.fieldPlaceholder(firstName), text: $message)
                .padding(.vertical, 7.0)
                .padding(.leading, 16.0)
                .padding(.trailing, 4.0)
                .font(Font.system(size: 13, weight: .regular))
                .foregroundColor(.primary)
                .textFieldStyle(.plain)

            Button { print("Send tapped") } label: {
                Image(systemName: "paperplane.circle.fill")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(Asset.Color.Button.primary.swiftUIColor)
                    .padding(3)
            }
            .buttonStyle(.plain)
            .unredacted()
            .disabled(redactionReasons.contains(.placeholder))
        }
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.background)
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Asset.Color.Border.secondary.swiftUIColor)
            }
        )
    }
}

struct MessageBarTextField_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MessageBarTextField(
                firstName: "Valerian",
                message: .constant("This is a message that was written.")
            )
            .previewDisplayName("Simple message")
            MessageBarTextField(
                firstName: "Valerian",
                message: .constant("This is a \(Array(repeating: "very", count: 20).joined(separator: " ")) long message that was written.")
            )
            .previewDisplayName("Long message")
            MessageBarTextField(
                firstName: "Very \(Array(repeating: "very", count: 20).joined(separator: " ")) long username",
                message: .constant("")
            )
            .previewDisplayName("Long username")
            MessageBarTextField(
                firstName: "Valerian",
                message: .constant("")
            )
            .previewDisplayName("Empty")
            MessageBarTextField(
                firstName: "Valerian",
                message: .constant("")
            )
            .padding()
            .background(Color.pink)
            .previewDisplayName("Colorful background")
        }
        .preferredColorScheme(.light)
        Group {
            MessageBarTextField(
                firstName: "Valerian",
                message: .constant("This is a message that was written.")
            )
            .previewDisplayName("Simple message / Dark")
            MessageBarTextField(
                firstName: "Valerian",
                message: .constant("")
            )
            .previewDisplayName("Empty / Dark")
            MessageBarTextField(
                firstName: "Valerian",
                message: .constant("")
            )
            .padding()
            .background(Color.pink)
            .previewDisplayName("Colorful background / Dark")
        }
        .preferredColorScheme(.dark)
    }
}
