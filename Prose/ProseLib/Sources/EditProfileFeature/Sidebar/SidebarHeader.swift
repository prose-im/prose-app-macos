//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ProseUI
import SwiftUI

struct SidebarHeader: View {
  @State var isAvatarHovered: Bool = false

  let action: () -> Void

  var body: some View {
    VStack {
      Button(action: action, label: avatar)
        .buttonStyle(.plain)
      Text(verbatim: "Baptiste Jamin")
        .font(.headline)
      Text(verbatim: "baptiste@crisp.chat")
        .font(.subheadline.monospaced())
        .foregroundColor(.secondary)
    }
    .multilineTextAlignment(.center)
  }

  @ViewBuilder
  func avatar() -> some View {
    let avatar = Avatar(.placeholder, size: 80, cornerRadius: 12)
    avatar
      .overlay {
        ZStack(alignment: .bottom) {
          Color.black.opacity(0.125)
          Text("edit")
            .font(.callout.bold())
            .foregroundColor(.white)
            .padding(8)
        }
        .clipShape(avatar.shape)
        .opacity(isAvatarHovered ? 1 : 0)
      }
      .onHover {
        self.isAvatarHovered = $0
        // FIXME: Use TCA and in-flight effect cancellation to avoid running `NSCursor.pop()` if some other view is asking for `NSCursor.pointingHand.push()`.
        DispatchQueue.main.async {
          if self.isAvatarHovered {
            NSCursor.pointingHand.push()
          } else {
            NSCursor.pop()
          }
        }
      }
  }
}

struct SidebarHeader_Previews: PreviewProvider {
  static var previews: some View {
    SidebarHeader {}
      .padding()
    SidebarHeader(isAvatarHovered: true) {}
      .padding()
      .previewDisplayName("Avatar hovered")
  }
}
