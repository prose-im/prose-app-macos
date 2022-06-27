import Foundation
import ProseCoreClientFFI
import Toolbox

extension BareJid: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = (try? ProseCoreClientFFI.parseJid(jid: value)).expect("Invalid JID.")
    }
}
