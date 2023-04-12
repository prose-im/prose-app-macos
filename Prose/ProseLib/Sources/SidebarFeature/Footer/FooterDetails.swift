//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import Assets
import SwiftUI

struct FooterDetails: View {
  let teamName: String
  let statusIcon: Character
  let statusMessage: String

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(self.teamName)
        .font(.system(size: 12, weight: .bold))
        .foregroundColor(Colors.Text.primary.color)

      Text("\(String(self.statusIcon)) “\(self.statusMessage)”")
        .font(.system(size: 11))
        .foregroundColor(Colors.Text.secondary.color)
        .layoutPriority(1)
    }
    // Make hit box full width
    .frame(maxWidth: .infinity, alignment: .leading)
    .contentShape([.interaction, .focusEffect], Rectangle())
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("\(L10n.Server.ConnectedTo.label(self.teamName)), \(self.statusMessage)")
  }
}

struct FooterDetails_Previews: PreviewProvider {
  private struct Preview: View {
    var body: some View {
      FooterDetails(
        teamName: "Crisp",
        statusIcon: "🚀",
        statusMessage: "Building new stuff."
      )
      .frame(maxWidth: 256)
      .padding()
      .previewLayout(.sizeThatFits)
    }
  }

  static var previews: some View {
    Preview()
      .preferredColorScheme(.light)
      .previewDisplayName("Light")
    Preview()
      .preferredColorScheme(.dark)
      .previewDisplayName("Dark")
    Preview()
      .redacted(reason: .placeholder)
      .previewDisplayName("Placeholder")
  }
}
