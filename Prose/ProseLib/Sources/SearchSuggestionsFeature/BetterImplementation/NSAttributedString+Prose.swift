//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppKit.NSTextAttachment
import Foundation

extension NSAttributedString {
  /// Finds the index after the last attachment before the given index.
  ///
  /// If we say `"📄"` is an attachment, and `"|"` is the `startIndex`, then
  /// ```swift
  /// "  some📄 tex|t 📄 some other text  "
  /// ```
  /// would return `7`, as shown here with `"|"`:
  /// ```swift
  /// "  some📄| text 📄 some other text  "
  /// ```
  ///
  /// - Parameter endIndex: The index to start from (going backwards), or `nil` to start at the end.
  func prose_endIndexOfLastAttachment(before endIndex: Int? = nil) -> Int? {
    var index = (endIndex ?? self.length) - 1
    while index >= 0 {
      // Stop if we find the `.attachment` attribute
      if self.attribute(.attachment, at: index, effectiveRange: nil) != nil {
        return index + 1
      }

      // Stop if the character is `NSTextAttachment.character`
      if (self.string as NSString).character(at: index) == NSTextAttachment.character {
        return index + 1
      }

      index -= 1
    }
    // We have to check index `0`, which means we end up with `-1` if we don't `return` earlier.
    return index + 1
  }

  func prose_rangeFromLastAttachment(to endIndex: Int? = nil) -> NSRange {
    let endIndex: Int = endIndex ?? (self.length - 1)

    let startIndex: Int = self.prose_endIndexOfLastAttachment(before: endIndex) ?? 0
    return NSRange(location: startIndex, length: endIndex - startIndex)
  }

  func prose_rangeFromLastAttachmentToCaret(selectionRange: NSRange) -> NSRange {
    self.prose_rangeFromLastAttachment(to: selectionRange.upperBound)
  }
}
