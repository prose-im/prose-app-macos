//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import ComposableArchitecture
import Foundation

#warning("Remove me?")

struct RosterState: Equatable {
//  var roster: Roster = .init(groups: [])
//  var unreadCounts = [BareJid: Int]()
//  var presences = [BareJid: Presence]()
}

extension SessionState<RosterState> {
  var sidebar: SidebarRoster {
    var groups = [String: [SidebarRoster.Group.Item]]()
    for item in self.selectedAccount.contacts {
      for group in item.groups {
        groups[group, default: []].append(.init(
          jid: item.jid,
          name: item.name,
          avatarURL: item.avatar,
          numberOfUnreadMessages: 0,
          status: item.availability
        ))
      }
    }

    return SidebarRoster(groups: groups.map { groupName, items in
      SidebarRoster.Group(name: groupName, items: items)
    })
  }
}

struct SidebarRoster: Equatable {
  var groups = [Group]()
}

extension SidebarRoster {
  struct Group: Equatable {
    var name: String
    var items = [Item]()
  }
}

extension SidebarRoster.Group {
  struct Item: Equatable {
    var jid: BareJid
    var name: String
    var avatarURL: URL?
    var numberOfUnreadMessages: Int
    var status: Availability
  }
}
