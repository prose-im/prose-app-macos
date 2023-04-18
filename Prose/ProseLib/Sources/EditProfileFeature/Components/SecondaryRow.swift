//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import SwiftUI

struct SecondaryRow<Content: View>: View {
  let label: String
  let content: () -> Content

  init(_ label: String, @ViewBuilder content: @escaping () -> Content) {
    self.label = label
    self.content = content
  }

  var body: some View {
    HStack {
      Text(verbatim: self.label)
        .font(.headline.weight(.medium))
        // Ignore as it's already the container label
        .accessibilityHidden(true)
      self.content()
    }
    .accessibilityElement(children: .contain)
    .accessibilityLabel(self.label)
  }
}

struct SecondaryRow_Previews: PreviewProvider {
  static var previews: some View {
    VStack(alignment: .leading) {
      SecondaryRow("Status:") {
        HStack(spacing: 4) {
          Image(systemName: "location.fill")
            .foregroundColor(.blue)
          Text(verbatim: "Automatic")
        }
      }
      SecondaryRow("Geolocation permission:") {
        Text(verbatim: "Allowed")
        Button("Manage") {}
          .controlSize(.small)
      }
    }
    .padding()
  }
}
