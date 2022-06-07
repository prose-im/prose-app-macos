//
//  JIDTests.swift
//  Prose
//
//  Created by Rémi Bardon on 07/06/2022.
//

@testable import SharedModels
import XCTest

final class JIDTests: XCTestCase {
    static func roundTripTest(input: String, output expectedJid: JID) {
        let expectedString = input
        let jid = JID.parse(input)
        XCTAssertEqual(jid, expectedJid)
        let string = JID.print(jid)
        XCTAssertEqual(string, expectedString)
    }

    override func setUp() {
        self.continueAfterFailure = false
    }

    func testSimpleJID() {
        Self.roundTripTest(
            input: "valerian@prose.org",
            output: JID(node: "valerian", domain: "prose.org", resource: nil)
        )
    }

    func testMinimalJID() {
        Self.roundTripTest(
            input: "prose.org",
            output: JID(node: nil, domain: "prose.org", resource: nil)
        )
    }

    func testCompleteJID() {
        Self.roundTripTest(
            input: "valerian@prose.org/phone",
            output: JID(node: "valerian", domain: "prose.org", resource: "phone")
        )
    }

    func testJIDWithDashes() {
        Self.roundTripTest(
            input: "first-second@third-fourth.fifth-sixth/seventh-eighth",
            output: JID(node: "first-second", domain: "third-fourth.fifth-sixth", resource: "seventh-eighth")
        )
    }

    func testJIDWithDoubleDashes() {
        Self.roundTripTest(
            input: "first--second@third--fourth.fifth--sixth/seventh--eighth",
            output: JID(node: "first--second", domain: "third--fourth.fifth--sixth", resource: "seventh--eighth")
        )
    }
}
