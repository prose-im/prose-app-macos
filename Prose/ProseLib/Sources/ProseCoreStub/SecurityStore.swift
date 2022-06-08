//
//  SecurityStore.swift
//  Prose
//
//  Created by Rémi Bardon on 03/06/2022.
//

import Foundation
import SharedModels

public struct SecurityStore {
    public let isIdentityVerified: (_ jid: JID) -> Bool
    public let encryptionFingerprint: (_ jid: JID) -> String?
}

public extension SecurityStore {
    static var stub: Self {
        Self(
            isIdentityVerified: StubSecurityStore.shared.isIdentityVerified(for:),
            encryptionFingerprint: StubSecurityStore.shared.encryptionFingerprint(for:)
        )
    }
}

/// This is just a simple store sending fake data.
/// It should not go into production, it's intended to dynamise the (currently static) app.
private final class StubSecurityStore {
    fileprivate static let shared = StubSecurityStore()

    let _isIdentityVerified: [JID: Bool] = [
        "alexandre@crisp.chat": true,
        "antoine@crisp.chat": true,
        "baptiste@crisp.chat": true,
        "camille@crisp.chat": true,
        "constellation-health@crisp.chat": true,
        "eliott@crisp.chat": true,
        "julien@thefamily.com": false,
        "valerian@crisp.chat": true,
    ]
    let _encryptionFingerprints: [JID: String] = [
        "alexandre@crisp.chat": "JUOF2",
        "antoine@crisp.chat": "Q2DZO",
        "baptiste@crisp.chat": "WQC7S",
        "camille@crisp.chat": "25UJQ",
        "constellation-health@crisp.chat": "W064L",
        "eliott@crisp.chat": "W5Z43",
        "julien@thefamily.com": "Q48PT",
        "valerian@crisp.chat": "1HHHW",
    ]

    private init() {}

    func isIdentityVerified(for jid: JID) -> Bool {
        self._isIdentityVerified[jid, default: false]
    }

    func encryptionFingerprint(for jid: JID) -> String? {
        self._encryptionFingerprints[jid]
    }
}
