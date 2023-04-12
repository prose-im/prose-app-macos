//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import SwiftUI

struct SidebarPartContextComponent: View {
  var avatar: String = "avatar-valerian"
  var teamName: String = "Crisp"
  var statusIcon: Character = "🚀"
  var statusMessage: String = "Building new stuff."

  var body: some View {
    VStack(spacing: 0) {
      Divider()

      HStack(spacing: 12) {
        // User avatar
        SidebarContextAvatarComponent(
          avatar: self.avatar,
          status: .online
        )

        // Team name + user status
        SidebarContextCurrentComponent(
          teamName: self.teamName,
          statusIcon: self.statusIcon,
          statusMessage: self.statusMessage
        )
        .layoutPriority(1)

        Spacer()

        // Quick action button
        SidebarContextActionsComponent()
      }
      .padding(.leading, 20.0)
      .padding(.trailing, 14.0)
      .frame(maxHeight: 64)
    }
    .frame(height: 64)
  }
}

struct SidebarPartContextComponent_Previews: PreviewProvider {
  static var previews: some View {
    SidebarPartContextComponent()
  }
}
