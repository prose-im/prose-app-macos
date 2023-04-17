//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ProseBackend
import ProseUI
import SwiftUI

struct ContactRow: View {
  var title: String
  var avatar: AvatarImage
  var count = 0
  var status: Availability = .unavailable

  var body: some View {
    HStack {
      Avatar(self.avatar, size: 18)

      HStack(alignment: .firstTextBaseline, spacing: 4) {
        Text(self.title)

        OnlineStatusIndicator(self.status)
      }

      Spacer()

      Counter(count: self.count)
    }
  }
}

#if DEBUG
  import PreviewAssets

  struct ContactRow_Previews: PreviewProvider {
    private struct Preview: View {
      var body: some View {
        ContactRow(
          title: "Valerian",
          avatar: AvatarImage(url: PreviewAsset.Avatars.valerian.customURL),
          count: 3
        )
        .frame(width: 196)
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
#endif
