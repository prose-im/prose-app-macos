//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import SwiftUI

public extension CGSize {
  var prose_edgeInsets: EdgeInsets {
    EdgeInsets(top: self.height, leading: self.width, bottom: self.height, trailing: self.width)
  }
}

public extension EdgeInsets {
  var prose_nsEdgeInsets: NSEdgeInsets {
    NSEdgeInsets(top: self.top, left: self.leading, bottom: self.bottom, right: self.trailing)
  }
  var prose_vInsets: CGFloat { self.top + self.bottom }
  var prose_hInsets: CGFloat { self.leading + self.trailing }
}
