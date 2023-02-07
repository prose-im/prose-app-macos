import Foundation
import ProseCore

public extension FullJid {
  var bareJid: BareJid {
    BareJid(node: self.node, domain: self.domain)
  }
}
