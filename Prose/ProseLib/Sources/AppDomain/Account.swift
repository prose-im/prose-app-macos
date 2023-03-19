import Foundation
import ProseCoreFFI

public struct Account: Hashable, Identifiable {
  public var jid: BareJid
  public var status: ConnectionStatus
  public var profile: UserProfile?
  public var roster: [RosterItem]
  public var avatar: URL?

  public var id: BareJid {
    self.jid
  }

  public init(
    jid: BareJid,
    status: ConnectionStatus,
    profile: UserProfile? = nil,
    roster: [RosterItem] = [],
    avatar: URL? = nil
  ) {
    self.jid = jid
    self.status = status
    self.profile = profile
    self.roster = roster
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
