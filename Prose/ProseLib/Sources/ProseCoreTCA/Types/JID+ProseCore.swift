import Foundation
@_implementationOnly import ProseCoreClientFFI
import SharedModels

extension JID {
    init(bareJid: ProseCoreClientFFI.BareJid) {
        self.init(rawValue: "\(bareJid.node ?? "")@\(bareJid.domain)")
    }
}
