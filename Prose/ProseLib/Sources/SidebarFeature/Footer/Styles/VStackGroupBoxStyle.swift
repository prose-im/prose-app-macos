//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import SwiftUI

struct VStackGroupBoxStyle: GroupBoxStyle {
  let alignment: HorizontalAlignment
  let spacing: CGFloat?

  func makeBody(configuration: Configuration) -> some View {
    VStack(alignment: self.alignment, spacing: self.spacing) { configuration.content }
  }
}
