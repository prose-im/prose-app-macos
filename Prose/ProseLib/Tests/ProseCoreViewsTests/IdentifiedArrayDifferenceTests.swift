//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import typealias IdentifiedCollections.IdentifiedArrayOf
@testable import ProseCoreViews
import XCTest

final class IdentifiedArrayDifferenceTests: XCTestCase {
  func testDifference() {
    struct Item: Equatable, Identifiable, ExpressibleByIntegerLiteral {
      let id: Int
      var content = UUID()
      init(id: Int) {
        self.id = id
      }

      init(integerLiteral value: IntegerLiteralType) {
        self.init(id: Int(value))
      }
    }

    let items: [Item] = [0, 1, 2, 3]

    let arrayBefore: IdentifiedArrayOf<Item> = [items[0], items[3], items[1]]
    var item3 = items[3]
    item3.content = UUID()
    let arrayAfter: IdentifiedArrayOf<Item> = [items[0], item3, items[2]]

    let diff = arrayAfter.difference(from: arrayBefore)
    XCTAssertEqual(diff.insertedIds, [2])
    XCTAssertEqual(diff.removedIds, [1])
    XCTAssertEqual(diff.updatedIds, [3])

    let oppositeDiff = arrayBefore.difference(from: arrayAfter)
    XCTAssertEqual(oppositeDiff.insertedIds, diff.removedIds)
    XCTAssertEqual(oppositeDiff.removedIds, diff.insertedIds)
    XCTAssertEqual(oppositeDiff.updatedIds, diff.updatedIds)
  }
}
