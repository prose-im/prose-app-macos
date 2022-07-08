//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import SwiftUI

enum SidebarRoute: Equatable {
  case identity, authentication, profile, encryption
}

struct Sidebar: View {
  @Binding var route: SidebarRoute

  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack(alignment: .leading) {
        SidebarRow(
          icon: "person.text.rectangle",
          headline: "Identity",
          subheadline: "Name, Phone, Email",
          isSelected: route == .identity
        ) { route = .identity }
        SidebarRow(
          icon: "lock",
          headline: "Authentication",
          subheadline: "Password, MFA",
          isSelected: route == .authentication
        ) { route = .authentication }
        SidebarRow(
          icon: "person",
          headline: "Profile",
          subheadline: "Job, Location",
          isSelected: route == .profile
        ) { route = .profile }
        SidebarRow(
          icon: "key",
          headline: "Encryption",
          subheadline: "Certificates, Keys",
          isSelected: route == .encryption
        ) { route = .encryption }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(16)
      .fixedSize()
    }
    .safeAreaInset(edge: .top, spacing: 0) {
      SidebarHeader { logger.trace("Edit profile picture tapped") }
        .padding([.horizontal, .top], 24)
        .padding(.bottom, 8)
    }
  }
}

struct Sidebar_Previews: PreviewProvider {
  struct Preview: View {
    @State var route: SidebarRoute = .identity
    var body: some View {
      Sidebar(route: $route)
    }
  }

  static var previews: some View {
    Preview()
  }
}
