//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppDomain
import ProseUI
import SwiftUI

/// Separated as its own view as we might need to reuse it someday.
struct ToolbarTitle: View {
  let name: String
  let status: Availability

  init(name: String, status: Availability = .unavailable) {
    self.name = name
    self.status = status
  }

  var body: some View {
    ContentCommonNameStatusComponent(
      name: self.name,
      status: self.status
    )
    .padding(.horizontal, 8)
  }
}

// struct ToolbarTitle_Previews: PreviewProvider {
//  static var previews: some View {
//    VStack(alignment: .leading) {
//      ToolbarTitle(
//        name: "Valerian Saliou",
//        status: .online
//      )
//      ToolbarTitle(
//        name: "Valerian Saliou",
//        status: .online
//      )
//      .redacted(reason: .placeholder)
//      .previewDisplayName("Placeholder")
//    }
//    .previewLayout(.sizeThatFits)
//  }
// }
