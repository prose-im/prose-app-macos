//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import OrderedCollections

public extension OrderedDictionary {
  /// Inserts a new element for the given key or removes it if already present.
  ///
  /// Example:
  /// ```
  /// var dict: OrderedDictionary<String, Set<Int>> = [
  ///   "first": [1, 2, 3],
  ///   "second": [1, 3],
  /// ]
  ///
  /// dict.prose_toggle(2, forKey: "first") // false
  /// print(dict) // ["first": [1, 3], "second": [1, 3]]
  ///
  /// dict.prose_toggle(2, forKey: "second") // true
  /// print(dict) // ["first": [1, 3], "second": [1, 2, 3]]
  /// ```
  ///
  /// - Parameters:
  ///   - element: An element to insert/remove.
  ///   - key: The key in which to search for the element.
  /// - Returns: `true` if the element was inserted, `false` if it was removed.
  @discardableResult mutating func prose_toggle<Element>(
    _ element: Element,
    forKey key: Key
  ) -> Bool where Value: SetAlgebra, Value.Element == Element {
    let inserted = self[key, default: Value()].prose_toggle(element)
    if !inserted, self[key]?.isEmpty == true {
      self.removeValue(forKey: key)
    }
    return inserted
  }
}
