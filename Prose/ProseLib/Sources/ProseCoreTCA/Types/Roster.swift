//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import ProseCoreFFI

public struct Roster: Equatable {
  public var groups: [Group]

  public init(groups: [Roster.Group]) {
    self.groups = groups
  }
}

public extension Roster {
  struct Group: Equatable {
    public var name: String
    public var items: [Item]

    public init(name: String, items: [Roster.Group.Item]) {
      self.name = name
      self.items = items
    }
  }
}

public extension Roster.Group {
  struct Item: Equatable {
    public var jid: BareJid
    public var subscription: Subscription

    public init(jid: BareJid, subscription: Roster.Group.Item.Subscription) {
      self.jid = jid
      self.subscription = subscription
    }
  }
}

public extension Roster.Group.Item {
  enum Subscription: String {
    case none
    case to
    case from
    case both
  }
}

//extension Roster {
//  init(roster: XmppRoster) {
//    self.init(groups: roster.groups.map(Group.init))
//  }
//}
//
//extension Roster.Group {
//  init(group: XmppRosterGroup) {
//    self.init(
//      name: group.name,
//      items: group.items.map(Item.init)
//    )
//  }
//}
//
//extension Roster.Group.Item {
//  init(item: XmppRosterItem) {
//    self.init(
//      jid: item.jid,
//      subscription: .init(subscription: item.subscription)
//    )
//  }
//}
//
//extension Roster.Group.Item.Subscription {
//  init(subscription: XmppRosterItemSubscription) {
//    switch subscription {
//    case .none:
//      self = .none
//    case .to:
//      self = .to
//    case .both:
//      self = .both
//    case .from:
//      self = .from
//    @unknown default:
//      fatalError("Unknown RosterItemSubscription \(subscription)")
//    }
//  }
//}
