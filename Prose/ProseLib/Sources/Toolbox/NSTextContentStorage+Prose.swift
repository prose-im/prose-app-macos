//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Cocoa

private extension NSRange {
  init(_ textRange: NSTextRange, in textContentManager: NSTextContentManager) {
    let offset = textContentManager.offset(
      from: textContentManager.documentRange.location,
      to: textRange.location
    )
    let length = textContentManager.offset(
      from: textRange.location,
      to: textRange.endLocation
    )
    self.init(location: offset, length: length)
  }

  init(_ textLocation: NSTextLocation, in textContentManager: NSTextContentManager) {
    let offset = textContentManager.offset(
      from: textContentManager.documentRange.location,
      to: textLocation
    )
    self.init(location: offset, length: 0)
  }
}

@available(macOS 12.0, *)
public extension NSTextContentStorage {
  /// - Warning: This implementation is naive. If there are multiple selections, we take the last range.
  func prose_selectionRange() -> NSRange? {
    guard let textLayoutManager = self.textLayoutManagers.first else {
      assertionFailure("`textLayoutManagers` is empty.")
      return nil
    }

    guard let textRange = textLayoutManager.textSelections.last?.textRanges.last else {
      // There is no selection
      return nil
    }

    return NSRange(textRange, in: self)
  }

  func prose_endIndexOfLastAttachment(before startLocation: NSTextLocation? = nil) -> Int? {
    guard let textLayoutManager = self.textLayoutManagers.first else {
      assertionFailure("`textLayoutManagers` is empty.")
      return nil
    }
    guard let attributedString = self.attributedString else {
      assertionFailure("You cannot search for attachment in a non-attributed string.")
      return nil
    }

    let startLocation: NSTextLocation = startLocation ?? self.documentRange.endLocation

    var endOfLastAttachment: Int?
    textLayoutManager.enumerateSubstrings(
      from: startLocation,
      options: [.byCaretPositions, .reverse]
    ) { (_, textRange: NSTextRange, _, stop: UnsafeMutablePointer<ObjCBool>) in
      // Transform `NSTextRange` into a `NSRange`
      let range = NSRange(textRange, in: self)

      // Find attachment
      let attachment = attributedString.attribute(
        .attachment,
        at: range.location,
        effectiveRange: nil
      )

      // Stop enumerating if we found an attachment
      if attachment != nil {
        endOfLastAttachment = range.upperBound
        stop.pointee = true
      }
    }

    return endOfLastAttachment ?? 0
  }

  func prose_rangeFromLastAttachment(to endLocation: NSTextLocation? = nil) -> NSRange {
    let endLocation = endLocation ?? self.documentRange.endLocation

    let start: Int = self.prose_endIndexOfLastAttachment(before: endLocation) ?? 0
    let end = NSRange(endLocation, in: self)
    return NSRange(location: start, length: end.upperBound - start)
  }

  /// - Note: If there are multiple selections, we take the last selection caret.
  func prose_rangeFromLastAttachmentToCaret() -> NSRange {
    guard let textLayoutManager = self.textLayoutManagers.first else {
      assertionFailure("`textLayoutManagers` is empty.")
      return NSRange(location: NSNotFound, length: 0)
    }
    let location: NSTextLocation? = textLayoutManager.textSelections.last?.textRanges.last?
      .endLocation

    return self.prose_rangeFromLastAttachment(to: location)
  }
}
