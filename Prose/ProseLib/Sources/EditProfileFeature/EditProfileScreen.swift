//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import SwiftUI

private let l10n = L10n.EditProfile.self

struct EditProfileScreen: View {
  @State var route: SidebarRoute = .identity

  var isSaveProfileButtonDisabled: Bool {
    switch self.route {
    case .identity, .profile:
      return false
    case .authentication, .encryption:
      return true
    }
  }

  var body: some View {
    NavigationView {
      Sidebar(route: $route)
      detailView()
        .frame(minWidth: 480, minHeight: 512)
        .safeAreaInset(edge: .bottom, alignment: .trailing) {
          HStack {
            Button(l10n.CancelAction.label) { logger.trace("Cancel profile editing tapped") }
            Button(l10n.SaveProfileAction.label) { logger.trace("Save profile tapped") }
              .buttonStyle(.borderedProminent)
              .disabled(self.isSaveProfileButtonDisabled)
          }
          .controlSize(.large)
          .padding(4)
          .background {
            RoundedRectangle(cornerRadius: 8)
              .fill(Material.regular)
          }
          .padding([.horizontal, .bottom])
          // Make sure accessibility frame isn't inset by the window's rounded corners
          .contentShape(Rectangle())
          // Make footer have a higher priority, to be accessible over the scroll view
          .accessibilitySortPriority(1)
        }
    }
  }

  @ViewBuilder
  func detailView() -> some View {
    switch self.route {
    case .identity:
      IdentityView()
    case .authentication:
      AuthenticationView()
    case .profile:
      ProfileView()
    case .encryption:
      EncryptionView()
    }
  }
}

struct EditProfileScreen_Previews: PreviewProvider {
  static var previews: some View {
    EditProfileScreen()
  }
}
