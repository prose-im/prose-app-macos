import Foundation
import ProseCoreTCA
import ProseCoreViews
import SnapshotTesting
import TestHelpers
import XCTest

final class FFITests: XCTestCase {
  func testRegularFunc() throws {
    var result = [String]()

    let ffi = FFI { jsString, _ in
      result.append(jsString)
    }

    ffi.messagingStore.interact(.reactions, .init(rawValue: "message-id"), true)

    XCTAssertEqual(result.count, 1)
    try assertSnapshot(matching: XCTUnwrap(result.first), as: .lines)
  }

  func testVariadicFunc() throws {
    var result = [String]()

    let ffi = FFI { jsString, _ in
      result.append(jsString)
    }

    ffi.messagingStore.insertMessages([
      .init(from: ProseCoreTCA.Message(
        from: "test@prose.org",
        id: .init(rawValue: "message-id"),
        kind: .chat,
        body: "Hello World",
        timestamp: .ymd(2022, 08, 10),
        isRead: true,
        isEdited: false
      )),
    ])

    XCTAssertEqual(result.count, 1)
    try assertSnapshot(matching: XCTUnwrap(result.first), as: .lines)
  }
  
  func testJIDEncoding() {
    var result = [String]()

    let ffi = FFI { jsString, _ in
      result.append(jsString)
    }

    ffi.messagingContext.setAccountJID("test@prose.org")

    XCTAssertEqual(result.count, 1)
    try assertSnapshot(matching: XCTUnwrap(result.first), as: .lines)
  }
}
