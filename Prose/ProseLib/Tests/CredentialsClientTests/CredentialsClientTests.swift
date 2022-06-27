//
//  CredentialsClientTests.swift
//  Prose
//
//  Created by Rémi Bardon on 15/06/2022.
//

@testable import CredentialsClient
import ProseCoreTCA
import XCTest

final class CredentialsStoreTests: XCTestCase {
    func testSavesUpdatesAndDeletesCredentials() throws {
        let store = CredentialsClient.live(service: "org.prose.app.tests")

        let jid: JID = "tests@prose.org"

        try XCTAssertNil(store.loadCredentials(jid))

        let initialCredentials = Credentials(jid: jid, password: "initial-password")

        try store.save(initialCredentials)

        try XCTAssertEqual(store.loadCredentials(jid), initialCredentials)

        let updatedCredentials = Credentials(jid: jid, password: "updated-passowrd")

        try store.save(updatedCredentials)

        try XCTAssertEqual(store.loadCredentials(jid), updatedCredentials)

        try store.deleteCredentials(jid)

        try XCTAssertNil(store.loadCredentials(jid))
    }
}
