import Foundation
import ProseCoreClientFFI

public typealias ProseClientProvider<Client: ProseClientProtocol> =
    (BareJid, ProseClientDelegate) -> Client

public protocol ProseClientProtocol: AnyObject {
    var jid: BareJid { get }

    func connect(credential: Credential) throws
    func disconnect()

    func sendMessage(to jid: BareJid, text: String) throws
    func loadRoster() throws
}

public protocol ProseClientDelegate: AnyObject {
    func proseClientDidConnect(_ client: ProseClientProtocol)
    func proseClient(
        _ client: ProseClientProtocol,
        connectionDidFailWith error: Error?
    )

    func proseClient(
        _ client: ProseClientProtocol,
        didReceiveRoster roster: ProseCoreClientFFI.Roster
    )
    func proseClient(
        _ client: ProseClientProtocol,
        didReceiveMessage message: ProseCoreClientFFI.Message
    )
}
