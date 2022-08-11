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

  func convert<T: Encodable>(_ value: T) throws -> String {
    let data = try self.encoder.encode(value)
    return String(data: data, encoding: .utf8).expect("\(value) has invalid UTF-8")
  }

  func testJIDEncoding() throws {
    func convert(_ jid: JID) throws -> String {
      try self.convert(jid)
    }

    XCTAssertEqual(try convert("test@prose.org"), #""test@prose.org""#)
    XCTAssertEqual(try convert("test@prose.org/resource"), #""test@prose.org""#)
  }

  func testReactionEncoding() throws {
    func convert(_ reaction: Reaction) throws -> String {
      try self.convert(reaction)
    }

    XCTAssertEqual(try convert("😀"), #""😀""#)
    XCTAssertEqual(try convert("test"), #""test""#)
  }

  func testMessageReactionsEncoding() throws {
    func convert(_ reactions: MessageReactions) throws -> String {
      try self.convert(reactions)
    }

    XCTAssertEqual(
      try convert(["😀": ["tests1@prose.org"], "🧪": ["tests2@prose.org"]]),
      #"[{"authors":["tests1@prose.org"],"reaction":"😀"},{"authors":["tests2@prose.org"],"reaction":"🧪"}]"#
    )
    XCTAssertEqual(
      try convert(["🧪": ["tests2@prose.org"], "😀": ["tests1@prose.org"]]),
      #"[{"authors":["tests2@prose.org"],"reaction":"🧪"},{"authors":["tests1@prose.org"],"reaction":"😀"}]"#
    )
    XCTAssertEqual(
      try convert(["🧪": [], "😀": ["tests1@prose.org"]]),
      #"[{"authors":["tests1@prose.org"],"reaction":"😀"}]"#
    )
    XCTAssertEqual(
      try convert(["2️⃣": ["tests1@prose.org", "tests2@prose.org"]]),
      #"[{"authors":["tests1@prose.org","tests2@prose.org"],"reaction":"2️⃣"}]"#
    )
    XCTAssertEqual(
      try convert(["2️⃣": ["tests2@prose.org", "tests1@prose.org"]]),
      #"[{"authors":["tests2@prose.org","tests1@prose.org"],"reaction":"2️⃣"}]"#
    )
    XCTAssertEqual(try convert([:]), #"[]"#)
  }

  func testMessageEncoding() throws {
    func convert(_ message: Message) throws -> String {
      try self.convert(message)
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
    XCTAssertEqual(
      try convert(message),
      """
      {"content":"Hello unit tests","date":"2022-08-11T00:00:00.000Z",\
      "from":{"jid":"remi@prose.org","name":"remi@prose.org"},\
      "id":"test-message-id",\
      "reactions":[{"authors":["remi@prose.org"],"reaction":"👋"}],\
      "type":"text"}
      """
    )
  }
}
