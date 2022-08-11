//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ProseCoreTCA
import XCTest

final class TypesEncodingTests: XCTestCase {
  let encoder: JSONEncoder = {
    let encoder = JSONEncoder()
    // Sort object keys so results are predictable
    encoder.outputFormatting = .sortedKeys
    return encoder
  }()

  func check<T: Encodable>(_ value: T, equals expected: String) throws {
    let data = try self.encoder.encode(value)
    let string = String(data: data, encoding: .utf8).expect("\(value) has invalid UTF-8")
    XCTAssertEqual(string, expected)
  }

  func check<T: Encodable>(_ value: T, in expectedOneOf: [String]) throws {
    let data = try self.encoder.encode(value)
    let string = String(data: data, encoding: .utf8).expect("\(value) has invalid UTF-8")
    XCTAssertTrue(expectedOneOf.contains(string))
  }

  func testJIDEncoding() throws {
    func test(_ jid: JID, equals expected: String) throws {
      try self.check(jid, equals: expected)
    }

    try test("test@prose.org", equals: #""test@prose.org""#)
    try test("test@prose.org/resource", equals: #""test@prose.org""#)
  }

  func testReactionEncoding() throws {
    func test(_ reaction: Reaction, equals expected: String) throws {
      try self.check(reaction, equals: expected)
    }

    try test("😀", equals: #""😀""#)
    try test("test", equals: #""test""#)
  }

  func testMessageReactionsEncoding() throws {
    func test(_ reactions: MessageReactions, equals expected: String) throws {
      try self.check(reactions, equals: expected)
    }
    func test(_ reactions: MessageReactions, in expectedOneOf: [String]) throws {
      try self.check(reactions, in: expectedOneOf)
    }

    try test(
      ["😀": ["tests1@prose.org"], "🧪": ["tests2@prose.org"]],
      equals: #"[{"authors":["tests1@prose.org"],"reaction":"😀"},{"authors":["tests2@prose.org"],"reaction":"🧪"}]"#
    )
    try test(
      ["🧪": ["tests2@prose.org"], "😀": ["tests1@prose.org"]],
      equals: #"[{"authors":["tests2@prose.org"],"reaction":"🧪"},{"authors":["tests1@prose.org"],"reaction":"😀"}]"#
    )
    try test(
      ["🧪": [], "😀": ["tests1@prose.org"]],
      equals: #"[{"authors":["tests1@prose.org"],"reaction":"😀"}]"#
    )
    // Reaction authors is stored in a `Set`, so we can't predict the output
    try test(
      ["2️⃣": ["tests1@prose.org", "tests2@prose.org"]],
      in: [
        #"[{"authors":["tests1@prose.org","tests2@prose.org"],"reaction":"2️⃣"}]"#,
        #"[{"authors":["tests2@prose.org","tests1@prose.org"],"reaction":"2️⃣"}]"#,
      ]
    )
    try test([:], equals: #"[]"#)
  }

  func testMessageEncoding() throws {
    func test(_ message: Message, equals expected: String) throws {
      try self.check(message, equals: expected)
    }

    var message = Message(
      from: "remi@prose.org",
      id: "test-message-id",
      kind: .chat,
      body: "Hello unit tests",
      timestamp: Date.ymd(2022, 08, 11, timeZone: .init(abbreviation: "GMT")!),
      isRead: false,
      isEdited: false
    )
    message.reactions = ["👋": ["remi@prose.org"]]
    try test(
      message,
      equals: """
      {"content":"Hello unit tests","date":"2022-08-11T00:00:00.000Z",\
      "from":{"jid":"remi@prose.org","name":"remi@prose.org"},\
      "id":"test-message-id",\
      "reactions":[{"authors":["remi@prose.org"],"reaction":"👋"}],\
      "type":"text"}
      """
    )
  }

  // [{"from":{"jid":"valerian@prose.org","name":"valerian@prose.org"},"id":"061629BD-50E5-41DD-BBE4-B88E7DD00151","content":"Hello preview 👋","reactions":[{"authors":["preview@prose.org"],"reaction":"👋"}],"type":"text","date":"2022-08-10T13:58:41.048Z"},{"from":{"jid":"preview@prose.org","name":"preview@prose.org"},"id":"1C7ABBDA-596D-4B97-999B-60EC0AEA7D32","content":"Hi!","reactions":[{"authors":["valerian@prose.org"],"reaction":"😃"}],"type":"text","date":"2022-08-10T14:01:49.049Z"},{"from":{"jid":"preview@prose.org","name":"preview@prose.org"},"id":"2652A9AA-1E12-487B-BA4A-DA7577182B63","content":"How are you?","reactions":[],"type":"text","date":"2022-08-10T14:01:51.049Z"}]
}
