//
//  SidebarModel.swift
//  Prose
//
//  Created by Valerian Saliou on 11/15/21.
//  Copyright © 2022 Prose. All rights reserved.
//

import AppLocalization
import ConversationFeature
import ProseUI
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

public struct SidebarItem: Equatable, Identifiable {
    enum Image: Equatable {
        case avatar(AvatarImage), symbol(String)
    }

    public let id: SidebarRoute
    var title: String
    var image: Image
    var count: UInt16
}

public extension SidebarItem {
    static func unread(
        _ state: UnreadState = .init(),
        _ count: UInt16 = 0
    ) -> SidebarItem {
        SidebarItem(
            id: .unread(state),
            title: L10n.Sidebar.Spotlight.unreadStack,
            image: .symbol(Icon.unread.rawValue),
            count: count
        )
    }

    static func replies(
        _ count: UInt16 = 0
    ) -> SidebarItem {
        SidebarItem(
            id: .replies,
            title: L10n.Sidebar.Spotlight.replies,
            image: .symbol(Icon.reply.rawValue),
            count: count
        )
    }

    static func directMessages(
        _ count: UInt16 = 0
    ) -> SidebarItem {
        SidebarItem(
            id: .directMessages,
            title: L10n.Sidebar.Spotlight.directMessages,
            image: .symbol(Icon.directMessage.rawValue),
            count: count
        )
    }

    static func peopleAndGroups(
        _ count: UInt16 = 0
    ) -> SidebarItem {
        SidebarItem(
            id: .peopleAndGroups,
            title: L10n.Sidebar.Spotlight.peopleAndGroups,
            image: .symbol(Icon.group.rawValue),
            count: count
        )
    }

    static func person(
        _ jid: JID,
        title: String,
        image: AvatarImage = .placeholder,
        count: UInt16 = 0
    ) -> SidebarItem {
        SidebarItem(
            id: .chat(.init(chatId: .person(id: jid))),
            title: title,
            image: .avatar(image),
            count: count
        )
    }

    static func group(
        _ jid: JID,
        _ count: UInt16 = 0
    ) -> SidebarItem {
        SidebarItem(
            id: .chat(.init(chatId: .group(id: jid))),
            title: jid.node ?? "group",
            image: .symbol(Icon.group.rawValue),
            count: count
        )
    }
}

public struct UserCredentials: Equatable {
    public var jid: JID

    public init(jid: JID) {
        self.jid = jid
    }
}
