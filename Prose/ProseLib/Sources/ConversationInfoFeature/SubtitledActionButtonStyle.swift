//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Assets
import SwiftUI

struct SubtitledActionButtonStyle: ButtonStyle {
  private struct SubtitledLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
      VStack(spacing: 3) {
        ZStack {
          Circle().fill(Color.accentColor)
          configuration.icon
            .font(.system(size: 12))
            .foregroundColor(.white)
            .symbolVariant(.fill)
        }
        .frame(width: 24, height: 24)

        configuration.title
          // TODO: [Rémi Bardon] 9.5 is probably too small for accessibility checks
          .font(.system(size: 9.5))
          .foregroundColor(.accentColor)
          .layoutPriority(1)
      }
      // Allow hit testing between the label and the icon
      .contentShape(.interaction, Rectangle())
    }
  }

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .labelStyle(SubtitledLabelStyle())
      .opacity(configuration.isPressed ? 0.5 : 1)
  }
}

struct SubtitledActionButtonStyle_Previews: PreviewProvider {
  private struct Preview: View {
    var body: some View {
      VStack(spacing: 16) {
        // This looks bad, but it should not happen.
        // This button style should only be used with a `Label`.
        Button("Test", action: {})
        Button(action: {}) {
          Label("phone", systemImage: "phone")
        }
        Button(action: {}) {
          Label("email", systemImage: "envelope")
        }
        Button(action: {}) {
          Label("Bad image", systemImage: "")
        }
      }
      .buttonStyle(SubtitledActionButtonStyle())
      .padding()
    }
  }

  static var previews: some View {
    Preview()
      .preferredColorScheme(.light)
      .previewDisplayName("Light")

    Preview()
      .preferredColorScheme(.dark)
      .previewDisplayName("Dark")
  }
}
