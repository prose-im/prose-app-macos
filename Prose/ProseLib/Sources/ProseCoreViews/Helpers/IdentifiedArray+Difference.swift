//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import struct IdentifiedCollections.IdentifiedArray
import struct OrderedCollections.OrderedSet

extension IdentifiedArray where Element: Equatable {
  struct Difference: Equatable {
    let removedIds, insertedIds: OrderedSet<ID>
    let updatedIds: Set<ID>
  }

  func difference(from other: Self) -> Difference {
    let ids: OrderedSet<ID> = self.ids
    let otherIds: OrderedSet<ID> = other.ids

    return Difference(
      removedIds: otherIds.subtracting(ids),
      insertedIds: ids.subtracting(otherIds),
      updatedIds: Set(ids.intersection(otherIds)).filter { self[id: $0] != other[id: $0] }
    )
  }
}
