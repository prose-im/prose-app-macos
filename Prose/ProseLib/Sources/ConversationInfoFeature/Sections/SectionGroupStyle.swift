//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import SwiftUI

struct SectionGroupStyle: GroupBoxStyle {
  private static let sidesPadding: CGFloat = 15

  func makeBody(configuration: Configuration) -> some View {
    VStack(spacing: 8) {
      VStack(alignment: .leading, spacing: 2) {
        configuration.label
          .font(.system(size: 11, weight: .semibold))
          .foregroundColor(Color.primary.opacity(0.25))
          .padding(.horizontal, Self.sidesPadding)
          .unredacted()

        Divider()
      }

      configuration.content
        .font(.system(size: 13))
        .labelStyle(EntryRowLabelStyle())
        .padding(.horizontal, Self.sidesPadding)
    }
  }
}
