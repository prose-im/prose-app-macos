//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation

public extension AttributeContainer {
  var attributes: [NSAttributedString.Key: Any] {
    NSAttributedString(AttributedString(" ", attributes: self))
      .attributes(at: 0, effectiveRange: nil)
  }
}
