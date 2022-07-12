//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Assets
import ProseCoreTCA
import SwiftUI

public typealias OnlineStatusIndicator = BooleanIndicator

public extension OnlineStatusIndicator {
  init(
    status: OnlineStatus,
    size: CGFloat
  ) {
    self.init(bool: status == .online, size: size)
  }

  init(_ status: OnlineStatus) {
    self.init(status == .online)
  }
}

struct OnlineStatusIndicator_Previews: PreviewProvider {
  private struct Preview: View {
    var body: some View {
      HStack {
        ForEach(OnlineStatus.allCases, id: \.self, content: OnlineStatusIndicator.init(_:))
      }
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
