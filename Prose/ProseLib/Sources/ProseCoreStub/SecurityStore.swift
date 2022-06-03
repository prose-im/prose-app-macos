//
//  SecurityStore.swift
//  Prose
//
//  Created by Rémi Bardon on 03/06/2022.
//

import Foundation
import SharedModels

/// This is just a simple store sendiong fake data.
/// It should not go into production, it's intended to dynamise the (currently static) app.
public final class SecurityStore {
    public static let shared = SecurityStore()

    private let isIdentityVerified: [String: Bool] = [
        "id-alexandre": true,
        "id-antoine": true,
        "id-baptiste": true,
        "id-camille": true,
        "id-constellation-health": true,
        "id-eliott": true,
        "id-julien": false,
        "id-valerian": true,
    ]
    private let encryptionFingerprints: [String: String] = [
        "id-alexandre": "JUOF2",
        "id-antoine": "Q2DZO",
        "id-baptiste": "WQC7S",
        "id-camille": "25UJQ",
        "id-constellation-health": "W064L",
        "id-eliott": "W5Z43",
        "id-julien": "Q48PT",
        "id-valerian": "1HHHW",
    ]

    private init() {}

    public func isIdentityVerified(for userId: String) -> Bool {
        self.isIdentityVerified[userId, default: false]
    }

    public func encryptionFingerprint(for userId: String) -> String? {
        self.encryptionFingerprints[userId]
    }
}
