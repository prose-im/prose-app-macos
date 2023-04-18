//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import SwiftUI

public struct ContentCommonNameStatusComponent: View {
  var name: String
  var status: Availability = .unavailable

  public init(name: String, status: Availability = .unavailable) {
    self.name = name
    self.status = status
  }

  public var body: some View {
    HStack {
      OnlineStatusIndicator(self.status)
        .offset(x: 3, y: 1)
        .accessibilitySortPriority(1)

      Text(verbatim: self.name)
        .font(.system(size: 14).bold())
        .accessibilitySortPriority(2)
    }
    .accessibilityElement(children: .combine)
  }
}

struct ContentCommonNameStatusComponent_Previews: PreviewProvider {
  static var previews: some View {
    ContentCommonNameStatusComponent(
      name: "Valerian Saliou",
      status: .available
    )
  }
}
