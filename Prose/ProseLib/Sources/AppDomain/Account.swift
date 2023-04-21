//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import Foundation
import ProseCoreFFI

public struct Account: Hashable, Identifiable {
  public var jid: BareJid
  public var status: ConnectionStatus
  public var profile: UserProfile?
  public var contacts: [BareJid: Contact]
  public var avatar: URL?

  public var id: BareJid {
    self.jid
  }

  public init(
    jid: BareJid,
    status: ConnectionStatus,
    profile: UserProfile? = nil,
    contacts: [BareJid: Contact] = [:],
    avatar: URL? = nil
  ) {
    self.jid = jid
    self.status = status
    self.profile = profile
    self.contacts = contacts
    self.avatar = avatar
  }
}

public extension Account {
  var username: String {
    if let fullName = self.profile?.fullName {
      return fullName
    }
    if let nickname = self.profile?.nickname {
      return nickname
    }
    return (self.jid.node ?? self.jid.domain)
      .split(separator: ".", omittingEmptySubsequences: true)
      .joined(separator: " ")
      .localizedCapitalized
  }
}

public extension [Contact] {
  func contactsGroupedByJid() -> [BareJid: Contact] {
    .init(
      zip(self.map(\.jid), self),
      uniquingKeysWith: { _, last in last }
    )
  }
}
