import Foundation
import ProseCore

public struct Account: Hashable, Identifiable {
  public var jid: BareJid
  public var status: ConnectionStatus

  public var id: BareJid {
    self.jid
  }

  public init(jid: BareJid, status: ConnectionStatus) {
    self.jid = jid
    self.status = status
  }
}
