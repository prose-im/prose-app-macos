//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import OrderedCollections

public extension Dictionary {
  @discardableResult mutating func prose_toggle<Element>(
    _ element: Element,
    forKey key: Key
  ) -> Bool where Value == OrderedSet<Element> {
    let inserted = self[key, default: Value()].unordered.prose_toggle(element)
    if !inserted, self[key]?.isEmpty == true {
      self.removeValue(forKey: key)
    }
    return inserted
  }
}

public extension OrderedDictionary {
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

  @discardableResult mutating func prose_toggle<Element>(
    _ element: Element,
    forKey key: Key
  ) -> Bool where Value == OrderedSet<Element> {
    let inserted = self[key, default: Value()].unordered.prose_toggle(element)
    if !inserted, self[key]?.isEmpty == true {
      self.removeValue(forKey: key)
    }
    return inserted
  }
}
