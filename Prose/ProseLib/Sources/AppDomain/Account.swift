import Foundation
import ProseCore

public struct Account: Hashable {
  public var jid: BareJid
  public var status: ConnectionStatus

  public init(jid: BareJid, status: ConnectionStatus) {
    self.jid = jid
    self.status = status
  }
}
