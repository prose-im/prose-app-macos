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
        case let .chat(state):
            hasher.combine(10)
            hasher.combine(state.chatId)
        case .newMessage:
            hasher.combine(20)
        }
    }
}

struct SidebarItem: Equatable, Identifiable {
    let id: SidebarRoute
    let title: String
    let image: ImageSource
    let count: UInt16
}

public struct UserCredentials: Equatable {
    public var jid: JID

    public init(jid: JID) {
        self.jid = jid
    }
}
