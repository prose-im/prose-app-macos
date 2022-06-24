import Foundation
@_implementationOnly import ProseCoreClientFFI
import SharedModels

extension JID {
    init(bareJid: ProseCoreClientFFI.BareJid) {
        self.init(node: bareJid.node, domain: bareJid.domain, resource: nil)
    }
}
