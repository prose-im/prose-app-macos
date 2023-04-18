//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import SwiftUI

public struct ToolbarDivider: View {
  public init() {}

  public var body: some View {
    HStack {
      Divider()
        .frame(height: 24)
    }
  }
}
