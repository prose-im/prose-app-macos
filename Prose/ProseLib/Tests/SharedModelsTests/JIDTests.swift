//
//  JIDTests.swift
//  Prose
//
//  Created by Rémi Bardon on 07/06/2022.
//

@testable import SharedModels
import XCTest

final class JIDTests: XCTestCase {
    static func roundTripTest(input: String, output expectedJid: JID) throws {
        var input = input[...]
        let expectedString = input
        let jid = try jidParserPrinter.parse(&input)
        XCTAssertTrue(input.isEmpty, String(input))
        XCTAssertEqual(jid, expectedJid)
        let string = try jidParserPrinter.print(jid)
        XCTAssertEqual(string, expectedString)
    }

    override func setUp() {
        self.continueAfterFailure = false
    }

    func testSimpleJID() throws {
        try Self.roundTripTest(
            input: "valerian@prose.org",
            output: JID(node: "valerian", domain: "prose.org", resource: nil)
        )
    }

    func testMinimalJID() throws {
        try Self.roundTripTest(
            input: "prose.org",
            output: JID(node: nil, domain: "prose.org", resource: nil)
        )
    }

    func testCompleteJID() throws {
        try Self.roundTripTest(
            input: "valerian@prose.org/phone",
            output: JID(node: "valerian", domain: "prose.org", resource: "phone")
        )
    }

    func testJIDWithDashes() throws {
        try Self.roundTripTest(
            input: "first-second@third-fourth.fifth-sixth/seventh-eighth",
            output: JID(node: "first-second", domain: "third-fourth.fifth-sixth", resource: "seventh-eighth")
        )
    }

    func testJIDWithDoubleDashes() throws {
        try Self.roundTripTest(
            input: "first--second@third--fourth.fifth--sixth/seventh--eighth",
            output: JID(node: "first--second", domain: "third--fourth.fifth--sixth", resource: "seventh--eighth")
        )
    }

    func testIncorrectHnameThrows() {
        self.continueAfterFailure = true

        XCTAssertThrowsError(try jidDomain.parse("-test"))
        XCTAssertThrowsError(try jidDomain.parse("test-"))
        XCTAssertThrowsError(try jidDomain.parse("-test.com"))
        XCTAssertThrowsError(try jidDomain.parse("test.com-"))
        XCTAssertThrowsError(try jidDomain.parse(".test"))
        XCTAssertThrowsError(try jidDomain.parse("test."))
        XCTAssertThrowsError(try jidDomain.parse(".test.com"))
        XCTAssertThrowsError(try jidDomain.parse("test.com."))
    }
}
