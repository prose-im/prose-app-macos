//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import SwiftUI

public struct CommonToolbarActions: View {
  @Environment(\.redactionReasons) private var redactionReasons

  public init() {}

  public var body: some View {
    Button { logger.info("Search tapped") } label: {
      Label("Search", systemImage: "magnifyingglass")
    }
    .unredacted()
    .disabled(redactionReasons.contains(.placeholder))
    // https://github.com/prose-im/prose-app-macos/issues/48
    .disabled(true)
  }
}

// MARK: - Previews

struct CommonToolbarActions_Previews: PreviewProvider {
  private struct Preview: View {
    var body: some View {
      CommonToolbarActions()
        .padding()
        .previewLayout(.sizeThatFits)
    }
  }

  static var previews: some View {
    Preview()
    Preview()
      .preferredColorScheme(.dark)
      .previewDisplayName("Dark mode")
    Preview()
      .redacted(reason: .placeholder)
      .previewDisplayName("Placeholder")
  }
}
