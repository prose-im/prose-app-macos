//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppKit

public extension CursorClient {
  static func live() -> CursorClient {
    CursorClient(
      push: { cursor in
//        logger.trace("Setting cursor to \(String(describing: cursor))…")
        switch cursor {
        case .interactiveHover:
          NSCursor.pointingHand.push()
        }
      },
      pop: {
//        logger.trace("Resetting cursor…")
        NSCursor.pop()
      }
    )
  }
}
