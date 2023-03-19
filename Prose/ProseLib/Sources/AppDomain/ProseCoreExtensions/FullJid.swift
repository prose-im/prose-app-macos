import Foundation
import ProseCoreFFI

public extension FullJid {
  var bareJid: BareJid {
    BareJid(node: self.node, domain: self.domain)
  }
}
