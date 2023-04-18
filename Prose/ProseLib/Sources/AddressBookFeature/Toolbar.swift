//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import ProseUI
import SwiftUI

struct Toolbar: ToolbarContent {
  var body: some ToolbarContent {
    ToolbarItemGroup(placement: .navigation) {
      CommonToolbarNavigation()
    }

    ToolbarItemGroup {
      Self.actions()

      ToolbarDivider()

      CommonToolbarActions()
    }
  }

  static func actions() -> some View {
    Group {
      Button { logger.info("Add contact tapped") } label: {
        Label("Add contact", systemImage: "person.crop.circle.badge.plus")
      }
      Button { logger.info("Stack plus tapped") } label: {
        Label("Add group", systemImage: "rectangle.stack.badge.plus")
      }

      ToolbarDivider()

      Menu {
        // TODO: Add actions
        Text("TODO")
      } label: {
        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
      }
    }
    .unredacted()
  }
}

internal struct Toolbar_Previews: PreviewProvider {
  private struct Preview: View {
    var body: some View {
      HStack {
        Toolbar.actions()
      }
    }
  }

  static var previews: some View {
    Preview()
    Preview()
      .redacted(reason: .placeholder)
      .previewDisplayName("Placeholder")
  }
}
