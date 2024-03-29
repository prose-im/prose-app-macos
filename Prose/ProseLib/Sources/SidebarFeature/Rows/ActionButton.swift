//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import SwiftUI

struct ActionButton: View {
  let title: String
  let action: () -> Void

  var body: some View {
    Button(action: self.action) {
      Label(self.title, systemImage: "plus.square.fill")
        .symbolVariant(.fill)
        // Make hit box full width
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.interaction, Rectangle())
    }
    .buttonStyle(.plain)
  }
}

struct ActionRow_Previews: PreviewProvider {
  static var previews: some View {
    ActionButton(
      title: "sidebar_groups_add",
      action: {}
    )
    .frame(width: 196)
  }
}
