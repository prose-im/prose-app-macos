//
//  SidebarModel.swift
//  Prose
//
//  Created by Valerian Saliou on 11/15/21.
//  Copyright © 2022 Prose. All rights reserved.
//

import ConversationFeature
import SharedModels
import UnreadFeature

public enum SidebarRoute: Hashable {
    case unread(UnreadState), replies, directMessages, peopleAndGroups
    case chat(ConversationState)
    case newMessage

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .unread:
            hasher.combine(0)
        case .replies:
            hasher.combine(1)
        case .directMessages:
            hasher.combine(2)
        case .peopleAndGroups:
            hasher.combine(3)
        case .chat:
            hasher.combine(10)
        case .newMessage:
            hasher.combine(20)
        }
    }

    public static func caseEqual(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.unread, .unread),
             (.replies, .replies),
             (.directMessages, .directMessages),
             (.peopleAndGroups, .peopleAndGroups),
             (.chat, .chat),
             (.newMessage, .newMessage):
            return true
        default:
            return false
        }
    }

    public static func caseEqual(lhs: Self?, rhs: Self?) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case let (.some(lhs), .some(rhs)):
            return self.caseEqual(lhs: lhs, rhs: rhs)
        default:
            return false
        }
    }
}

struct SidebarItem: Equatable, Identifiable {
    let id: SidebarRoute
    let title: String
    let image: String
    let count: UInt16
}

public struct UserCredentials: Equatable {
    public var jid: String

    public init(jid: String) {
        self.jid = jid
    }
}
