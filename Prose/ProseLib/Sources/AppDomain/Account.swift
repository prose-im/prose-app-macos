//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import Foundation
import ProseCoreFFI

@dynamicMemberLookup
public struct Account: Hashable, Identifiable {
  public var jid: BareJid
  public var status: ConnectionStatus
  public var settings: AccountSettings
  public var profile: UserProfile?
  public var contacts: [BareJid: Contact]
  public var avatar: URL?

  public var id: BareJid {
    self.jid
  }

  public init(
    jid: BareJid,
    status: ConnectionStatus,
    settings: AccountSettings,
    profile: UserProfile? = nil,
    contacts: [BareJid: Contact] = [:],
    avatar: URL? = nil
  ) {
    self.jid = jid
    self.status = status
    self.settings = settings
    self.profile = profile
    self.contacts = contacts
    self.avatar = avatar
  }
}

public extension Account {
  subscript<T>(dynamicMember keyPath: WritableKeyPath<AccountSettings, T>) -> T {
    get { self.settings[keyPath: keyPath] }
    set { self.settings[keyPath: keyPath] = newValue }
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
