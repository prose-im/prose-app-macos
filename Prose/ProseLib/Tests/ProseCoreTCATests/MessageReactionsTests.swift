//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
@testable import ProseCoreTCA
import XCTest

final class MessageReactionsTests: XCTestCase {
  func testAddReaction() {
    var reactions = MessageReactions()
    reactions.addReaction("❤️", for: "1")
    reactions.addReaction("❤️", for: "1")
    reactions.addReaction("🤷‍♂️", for: "1")
    reactions.addReaction("🤷‍♂️", for: "2")
    reactions.addReaction("🫠", for: "2")

    XCTAssertEqual(reactions, ["❤️": ["1"], "🤷‍♂️": ["1", "2"], "🫠": ["2"]])
  }

  func testToggleReaction() {
    var reactions = MessageReactions()
    reactions.toggleReaction("❤️", for: "1")
    reactions.toggleReaction("❤️", for: "2")
    XCTAssertEqual(reactions, ["❤️": ["1", "2"]])

    reactions.toggleReaction("❤️", for: "1")
    XCTAssertEqual(reactions, ["❤️": ["2"]])

    reactions.toggleReaction("❤️", for: "2")
    XCTAssertEqual(reactions, [:])
  }

  func testSetReactions() {
    var reactions: MessageReactions = [
      "❤️": ["1", "2"],
      "🫠": ["2"],
      "🐇": ["2", "1"],
    ]

    // Test reactions are correctly changed
    reactions.setReactions(["🫠", "🐇"], for: "1")
    XCTAssertEqual(
      reactions,
      [
        "❤️": ["2"],
        "🫠": ["2", "1"],
        "🐇": ["2", "1"],
      ]
    )

    // Test reactions are not reordered
    reactions.setReactions(["❤️", "🫠", "🐇"], for: "2")
    XCTAssertEqual(
      reactions,
      [
        "❤️": ["2"],
        "🫠": ["2", "1"],
        "🐇": ["2", "1"],
      ]
    )

    // Test reactions are correctly removed
    reactions.setReactions([], for: "1")
    XCTAssertEqual(
      reactions,
      [
        "❤️": ["2"],
        "🫠": ["2"],
        "🐇": ["2"],
      ]
    )

    // Test dictionary keys are correctly removed
    reactions.setReactions([], for: "2")
    XCTAssertEqual(reactions, [:])
  }

  func testReactionsForJID() {
    let reactions: MessageReactions = [
      "❤️": ["1", "2"],
      "🤷‍♂️": ["1"],
      "🫠": ["2"],
    ]
    XCTAssertEqual(Set(reactions.reactions(for: "2")), ["❤️", "🫠"])
  }
}
