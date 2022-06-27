//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import Assets
import SwiftUI

private let l10n = L10n.Content.MessageBar.self

struct TypingIndicator: View {
  var typing: [String]

  var body: some View {
    // TODO: Handle plural in localization
    Text(l10n.composeTyping(ListFormatter.localizedString(byJoining: typing)))
      .padding(.vertical, 4.0)
      .padding(.horizontal, 16.0)
      .font(Font.system(size: 10.5, weight: .light))
      .foregroundColor(Colors.Text.secondary.color)
      .background(
        ZStack {
          RoundedRectangle(cornerRadius: 12)
            .fill(.background)
          RoundedRectangle(cornerRadius: 12)
            .strokeBorder(Colors.Border.tertiary.color)
        }
      )
      // TODO: [Rémi Bardon] Probably remove this, as 0.025≈0
      .shadow(color: .black.opacity(0.025), radius: 3, y: 1)
      .frame(maxWidth: .infinity, alignment: .leading)
  }
}

struct TypingIndicator_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      TypingIndicator(
        typing: ["Valerian"]
      )
      .padding()
      .previewDisplayName("Simple username")
      TypingIndicator(
        typing: ["Valerian"]
      )
      .padding()
      .background(Color.pink)
      .previewDisplayName("Colorful background")
    }
    .preferredColorScheme(.light)
    Group {
      TypingIndicator(
        typing: ["Valerian"]
      )
      .padding()
      .previewDisplayName("Simple username / Dark")
      TypingIndicator(
        typing: ["Valerian"]
      )
      .padding()
      .background(Color.pink)
      .previewDisplayName("Colorful background / Dark")
    }
    .preferredColorScheme(.dark)
  }
}
