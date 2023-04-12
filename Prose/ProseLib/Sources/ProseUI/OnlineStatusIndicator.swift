//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Assets
import ProseBackend
import ProseCoreTCA
import SwiftUI

public typealias OnlineStatusIndicator = LEDIndicator

public extension OnlineStatusIndicator {
  init(
    status: Availability,
    size: CGFloat
  ) {
    self.init(isOn: status != .unavailable, size: size)
  }

  init(_ status: Availability) {
    self.init(isOn: status != .unavailable)
  }
}

// struct OnlineStatusIndicator_Previews: PreviewProvider {
//  private struct Preview: View {
//    var body: some View {
//      HStack {
//        ForEach(OnlineStatus.allCases, id: \.self, content: OnlineStatusIndicator.init(_:))
//      }
//      .padding()
//      .previewLayout(.sizeThatFits)
//    }
//  }
//
//  static var previews: some View {
//    Preview()
//      .preferredColorScheme(.light)
//      .previewDisplayName("Light")
//    Preview()
//      .preferredColorScheme(.dark)
//      .previewDisplayName("Dark")
//    Preview()
//      .redacted(reason: .placeholder)
//      .previewDisplayName("Placeholder")
//  }
// }
