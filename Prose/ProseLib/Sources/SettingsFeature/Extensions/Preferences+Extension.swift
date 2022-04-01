//
//  Preferences+Extension.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import Preferences

extension Preferences.PaneIdentifier {
    static let general = Self("general")
    static let accounts = Self("accounts")
    static let notifications = Self("notifications")
    static let messages = Self("messages")
    static let calls = Self("calls")
    static let advanced = Self("advanced")
}
