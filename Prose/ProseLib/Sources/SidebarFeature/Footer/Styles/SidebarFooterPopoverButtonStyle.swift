//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import SwiftUI

struct SidebarFooterPopoverButtonStyle: ButtonStyle {
  @Environment(\.isEnabled) private var isEnabled
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .opacity((configuration.isPressed || !self.isEnabled) ? 0.5 : 1)
      .foregroundColor(Self.color(for: configuration.role))
      // Make hit box full width
      // NOTE: [Rémi Bardon] We could avoid making the hit box full width for destructive actions.
      .frame(maxWidth: .infinity, alignment: .leading)
      // Allow hits in the transparent areas
      .contentShape(Rectangle())
  }

  static func color(for role: ButtonRole?) -> Color? {
    switch role {
    case .some(.destructive):
      return .red
    default:
      return nil
    }
  }
}
