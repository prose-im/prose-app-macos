//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import SwiftUI

struct ContentSection<Content: View>: View {
  let header: String
  let footer: String
  let content: () -> Content

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(verbatim: self.header)
        .font(.title3.bold())
        .foregroundColor(.secondary)
        .multilineTextAlignment(.leading)
        .padding(.horizontal)
        // Ignore as it's already the container label
        .accessibilityHidden(true)
      self.content()
        .layoutPriority(1)
      Text(self.footer.asMarkdown)
        .font(.footnote)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.leading)
        .padding(.horizontal)
        .fixedSize(horizontal: false, vertical: true)
    }
    .accessibilityElement(children: .contain)
    .accessibilityLabel(self.header)
  }
}

struct ContentSection_Previews: PreviewProvider {
  static var previews: some View {
    ScrollView(.vertical) {
      ContentSection(
        header: "Current location",
        footer: """
        You can opt-in to automatic location updates based on your last used device location. It is handy if you travel a lot, and would like this to be auto-managed. Your current city and country will be shared, not your exact GPS location.

        **Note that geolocation permissions are required for automatic mode.**
        """
      ) {
        Color.red
          .frame(height: 256)
      }
    }
    .frame(height: 480)
  }
}
