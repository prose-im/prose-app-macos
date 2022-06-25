import ProseCoreClientFFI
import Foundation

extension BareJid: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = try! ProseCoreClientFFI.parseJid(jid: value)
  }
}
