//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ProseUI
import SwiftUI

struct IconRow: View {
  var title: String
  var icon: Icon
  var count = 0

  var body: some View {
    HStack {
      Label(title, systemImage: self.icon.rawValue)
        .frame(maxWidth: .infinity, alignment: .leading)
      Counter(count: count)
    }
  }
}

struct NavigationRow_Previews: PreviewProvider {
  static var previews: some View {
    IconRow(
      title: "Label",
      icon: .unread,
      count: 10
    )
  }
}
