//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation

public extension SetAlgebra {
  /// Inserts a new element or removes it if already present.
  ///
  /// Example:
  /// ```
  /// var ints: Set<Int> = [3, 1]
  ///
  /// ints.prose_toggle(2) // true
  /// print(dict) // [3, 1, 2]
  ///
  /// ints.prose_toggle(1) // false
  /// print(dict) // [3, 2]
  ///
  /// ints.prose_toggle(1) // true
  /// print(dict) // [3, 2, 1]
  /// ```
  ///
  /// - Parameter element: An element to insert/remove.
  /// - Returns: `true` if the element was inserted, `false` if it was removed.
  @discardableResult mutating func prose_toggle(_ element: Element) -> Bool {
    if self.contains(element) {
      self.remove(element)
      return false
    } else {
      self.insert(element)
      return true
    }
  }
}
