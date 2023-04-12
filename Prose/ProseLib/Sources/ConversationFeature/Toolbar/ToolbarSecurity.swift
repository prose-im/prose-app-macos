//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Assets
import ProseCoreFFI
import ProseCoreTCA
import SwiftUI

/// Separated as its own view as we might need to reuse it someday.
struct ToolbarSecurity: View {
  let jid: BareJid
  let isVerified: Bool

  var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: 4) {
      Image(systemName: self.isVerified ? "checkmark.seal.fill" : "xmark.seal.fill")
        .foregroundColor(self.isVerified ? Colors.State.green.color : .red)
        .accessibilityElement()
        .accessibilityLabel(self.isVerified ? "Verified" : "Not verified")
        .accessibilitySortPriority(1)

      Text(verbatim: String(describing: self.jid))
        .foregroundColor(Colors.Text.secondary.color)
        .accessibilitySortPriority(2)
    }
    .padding(.horizontal, 8)
    .accessibilityElement(children: .combine)
  }
}

#if DEBUG
  struct ToolbarSecurity_Previews: PreviewProvider {
    static var previews: some View {
      VStack(alignment: .leading) {
        ToolbarSecurity(
          jid: "valerian@prose.org",
          isVerified: true
        )
        ToolbarSecurity(
          jid: "valerian@prose.org",
          isVerified: false
        )
        ToolbarSecurity(
          jid: "valerian@prose.org",
          isVerified: false
        )
        .redacted(reason: .placeholder)
        .previewDisplayName("Placeholder")
      }
      .previewLayout(.sizeThatFits)
    }
  }
#endif
