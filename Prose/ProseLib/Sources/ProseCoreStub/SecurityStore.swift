//
//  SecurityStore.swift
//  Prose
//
//  Created by Rémi Bardon on 03/06/2022.
//

import Foundation
import SharedModels

/// This is just a simple store sending fake data.
/// It should not go into production, it's intended to dynamise the (currently static) app.
public final class SecurityStore {
    public static let shared = SecurityStore()

    private let isIdentityVerified: [JID: Bool] = [
        "alexandre@crisp.chat": true,
        "antoine@crisp.chat": true,
        "baptiste@crisp.chat": true,
        "camille@crisp.chat": true,
        "constellation-health@crisp.chat": true,
        "eliott@crisp.chat": true,
        "julien@thefamily.com": false,
        "valerian@crisp.chat": true,
    ]
    private let encryptionFingerprints: [JID: String] = [
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

    public func isIdentityVerified(for jid: JID) -> Bool {
        self.isIdentityVerified[jid, default: false]
    }

    public func encryptionFingerprint(for jid: JID) -> String? {
        self.encryptionFingerprints[jid]
    }
}
