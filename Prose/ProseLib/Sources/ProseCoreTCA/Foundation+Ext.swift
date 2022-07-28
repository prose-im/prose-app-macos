//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation

public extension Set {
  /// Inserts a new element or removes it if already present.
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

public extension Dictionary {
  @discardableResult mutating func prose_toggle<Element>(
    _ element: Element,
    forKey key: Key
  ) -> Bool where Value == Set<Element> {
    let inserted = self[key, default: Set<Element>()].prose_toggle(element)
    if !inserted, self[key]?.isEmpty == true {
      self.removeValue(forKey: key)
    }
    return inserted
  }
}
