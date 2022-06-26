import Foundation
import ProseCoreClientFFI

extension BareJid: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = try! ProseCoreClientFFI.parseJid(jid: value)
    }
}
