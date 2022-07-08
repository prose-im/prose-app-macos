//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ProseUI
import SwiftUI

private let l10n = L10n.EditProfile.Sidebar.Header.self

struct SidebarHeader: View {
  let avatar: AvatarImage = .placeholder
  let fullName: String = "Baptiste Jamin"
  let jid: String = "baptiste@crisp.chat"

  @State var isAvatarHovered: Bool = false

  let action: () -> Void

  var body: some View {
    VStack {
      Button(action: self.action, label: self.avatarView)
        .buttonStyle(.plain)
        .accessibilityLabel(l10n.ChangeAvatarAction.axLabel)
        .accessibilityHint(l10n.ChangeAvatarAction.axHint)
      VStack {
        Text(verbatim: self.fullName)
          .font(.headline)
        Text(verbatim: self.jid)
          .font(.subheadline.monospaced())
          .foregroundColor(.secondary)
      }
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(l10n.ProfileDetails.axLabel(self.fullName, self.jid))
      // Higher priority on the profile label
      .accessibilitySortPriority(1)
    }
    .multilineTextAlignment(.center)
  }

  @ViewBuilder
  func avatarView() -> some View {
    let avatar = Avatar(self.avatar, size: 80, cornerRadius: 12)
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
