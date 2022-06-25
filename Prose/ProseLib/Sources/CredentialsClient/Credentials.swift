//
//  Credentials.swift
//  Prose
//
//  Created by Rémi Bardon on 17/06/2022.
//

import Foundation
import ProseCoreTCA

public struct Credentials: Hashable {
    public let jid: JID
    public let password: String

    public init(
        jid: JID,
        password: String
    ) {
        self.jid = jid
        self.password = password
    }
}
