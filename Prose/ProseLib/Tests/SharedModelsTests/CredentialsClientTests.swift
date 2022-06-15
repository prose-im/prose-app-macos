//
//  CredentialsClientTests.swift
//  Prose
//
//  Created by Rémi Bardon on 15/06/2022.
//

@testable import SharedModels
import XCTest

final class CredentialsStoreTests: XCTestCase {
    func testSavesUpdatesAndDeletesCredentials() throws {
        let store = CredentialsClient.live(service: "org.prose.Prose.tests")

        let jid: JID = "tests@prose.org"

        try XCTAssertNil(store.loadCredentials(jid))

        let initialCredentials = "initial-password"

        try store.save(jid, initialCredentials)

        try XCTAssertEqual(store.loadCredentials(jid), initialCredentials)

        let updatedCredentials = "updated-passowrd"

        try store.save(jid, updatedCredentials)

        try XCTAssertEqual(store.loadCredentials(jid), updatedCredentials)

        try store.deleteCredentials(jid)

        try XCTAssertNil(store.loadCredentials(jid))
    }
}
