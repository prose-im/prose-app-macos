//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import SwiftUI

public extension NSSize {
  var prose_edgeInsets: EdgeInsets {
    EdgeInsets(top: self.height, leading: self.width, bottom: self.height, trailing: self.width)
  }
}
