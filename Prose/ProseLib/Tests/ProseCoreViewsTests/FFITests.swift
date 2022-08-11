//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import ProseCoreTCA
@testable import ProseCoreViews
import TestHelpers
import XCTest

private struct Enc: Encodable {
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode("OK")
  }
}

private final class TestEvaluator {
  var scripts = [String]()

  func evaluateJS(
    _ javaScriptString: String,
    _ completionHandler: @escaping ((Any?, Error?) -> Void)
  ) {
    self.scripts.append(javaScriptString)
    completionHandler(nil, nil)
  }
}

final class FFITests: XCTestCase {
  func testFunc1Encodes() throws {
    let eval = TestEvaluator()
    let cls = JSClass(name: "MyClass", evaluator: eval.evaluateJS)
    let f: JSFunc1<Enc, Void> = cls.my_func
    f(Enc())
    try XCTAssertEqual(XCTUnwrap(eval.scripts.first), #"MyClass.my_func("OK")"#)
  }

  func testFunc2Encodes() throws {
    let eval = TestEvaluator()
    let cls = JSClass(name: "MyClass", evaluator: eval.evaluateJS)
    let f: JSFunc2<Enc, Enc, Void> = cls.my_func
    f(Enc(), Enc())
    try XCTAssertEqual(XCTUnwrap(eval.scripts.first), #"MyClass.my_func("OK", "OK")"#)
  }

  func testFunc3Encodes() throws {
    let eval = TestEvaluator()
    let cls = JSClass(name: "MyClass", evaluator: eval.evaluateJS)
    let f: JSFunc3<Enc, Enc, Enc, Void> = cls.my_func
    f(Enc(), Enc(), Enc())
    try XCTAssertEqual(XCTUnwrap(eval.scripts.first), #"MyClass.my_func("OK", "OK", "OK")"#)
  }

  func testRestFunc1Encodes() throws {
    let eval = TestEvaluator()
    let cls = JSClass(name: "MyClass", evaluator: eval.evaluateJS)
    let f: JSRestFunc1<[Enc], Void> = cls.my_func
    f([Enc(), Enc()])
    try XCTAssertEqual(XCTUnwrap(eval.scripts.first), #"MyClass.my_func(...["OK","OK"])"#)
  }

  func testJSResultValue() throws {
    let cls = JSClass(name: "MyClass") { _, completion in
      completion("Hello World", nil)
    }
    let f: JSRestFunc1<Int, String> = cls.my_func
    try XCTAssertEqual(self.await(f(0)), "Hello World")
  }

  func testJSError() throws {
    enum JSError: Error {
      case failure
    }
    let cls = JSClass(name: "MyClass") { _, completion in
      completion(nil, JSError.failure)
    }
    let f: JSRestFunc1<Int, String> = cls.my_func
    try XCTAssertThrowsError(self.await(f(0)))
  }

  // Tiny smoke test for the general MessagingStore setup
  func testMessagingStoreSmoke() throws {
    let eval = TestEvaluator()
    let ffi = FFI(evaluator: eval.evaluateJS)
    ffi.messagingStore.interact(.init(rawValue: "message-id"), .reactions, true)
    try XCTAssertEqual(
      XCTUnwrap(eval.scripts.first),
      #"MessagingStore.interact("message-id", "reactions", true)"#
    )
  }

  func testJIDEncoding() throws {
    let eval = TestEvaluator()
    let cls = JSClass(name: "MyClass", evaluator: eval.evaluateJS)
    let f: JSFunc1<JID, Void> = cls.my_func
    f("test@prose.org")
    try XCTAssertEqual(XCTUnwrap(eval.scripts.first), #"MyClass.my_func("test@prose.org")"#)
  }
}
