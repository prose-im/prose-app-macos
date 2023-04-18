//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import SwiftUI

public struct CommonToolbar: ToolbarContent {
  public init() {}

  public var body: some ToolbarContent {
    ToolbarItemGroup(placement: .navigation) {
      CommonToolbarNavigation()
    }

    ToolbarItemGroup {
      CommonToolbarActions()
    }
  }
}
