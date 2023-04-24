//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
@testable import CredentialsClient
import XCTest

final class CredentialsStoreTests: XCTestCase {
  func testSavesUpdatesAndDeletesCredentials() throws {
    let store = CredentialsClient.live(service: "org.prose.app.tests")

    let jid: BareJid = "tests@prose.org"

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
