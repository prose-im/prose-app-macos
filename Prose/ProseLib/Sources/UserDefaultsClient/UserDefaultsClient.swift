//
//  UserDefaultsClient.swift
//  Prose
//
//  Created by Rémi Bardon on 15/06/2022.
//

import Foundation
import SharedModels

public struct UserDefaultsClient {
    public var loadCurrentAccount: () -> JID?
    public var saveCurrentAccount: (_ jid: JID) -> Void
}

public extension UserDefaultsClient {
    static func live(_ defaults: UserDefaults) -> Self {
        Self(
            loadCurrentAccount: {
                defaults.string(forKey: "jid").flatMap(JID.init(rawValue:))
            },
            saveCurrentAccount: { jid in
                defaults.set(jid.jidString, forKey: "jid")
            }
        )
    }
}
