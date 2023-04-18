//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import SwiftUI

/// This is supposed to look like a macOS "Gradient button".
/// See https://developers.apple.com/design/human-interface-guidelines/components/menus-and-actions/buttons#gradient-buttons/
/// for more information.
public struct TableFooterButton: View {
  let systemImage: String
  let leadingDivider: Bool
  let trailingDivider: Bool
  let disclosureIndicator: Bool
  let action: () -> Void

  public init(
    systemImage: String,
    leadingDivider: Bool = false,
    trailingDivider: Bool = false,
    disclosureIndicator: Bool = false,
    action: @escaping () -> Void
  ) {
    self.systemImage = systemImage
    self.leadingDivider = leadingDivider
    self.trailingDivider = trailingDivider
    self.disclosureIndicator = disclosureIndicator
    self.action = action
  }

  public var body: some View {
    if self.leadingDivider || self.trailingDivider {
      HStack(spacing: 0) {
        self.divider(isVisible: self.leadingDivider)
        self.button()
        self.divider(isVisible: self.trailingDivider)
      }
    } else {
      self.button()
    }
  }

  func button() -> some View {
    Button(action: self.action) {
      HStack(spacing: 1) {
        Image(systemName: self.systemImage)
        if self.disclosureIndicator {
          Image(systemName: "chevron.down")
            .font(.system(size: 8, weight: .medium))
        }
      }
      .font(.system(size: 11, weight: .medium))
      .foregroundColor(.primary)
      // Make tap area bigger
      .padding(.horizontal, 6)
      .frame(maxHeight: .infinity)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }

  @ViewBuilder
  func divider(isVisible: Bool) -> some View {
    if isVisible {
      Divider()
        .padding(.vertical, 3.0)
    }
  }
}

struct TableFooterButton_Previews: PreviewProvider {
  static var previews: some View {
    HStack {
      Group {
        TableFooterButton(systemImage: "plus") {}
        TableFooterButton(systemImage: "plus", leadingDivider: true, trailingDivider: true) {}
        TableFooterButton(systemImage: "plus", trailingDivider: true) {}
        TableFooterButton(systemImage: "gear", disclosureIndicator: true) {}
      }
      .padding(1)
      .border(Color.red.opacity(0.125))
    }
    .frame(height: 22)
    .padding()
  }
}
