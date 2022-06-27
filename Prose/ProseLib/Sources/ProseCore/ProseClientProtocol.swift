import Foundation
import ProseCoreClientFFI

public typealias ProseClientProvider<Client: ProseClientProtocol> =
    (BareJid, ProseClientDelegate) -> Client

public protocol ProseClientProtocol: AnyObject {
    var jid: BareJid { get }

    func connect(credential: Credential) throws
    func disconnect()

    func sendMessage(
        id: String,
        to: BareJid,
        text: String,
        chatState: ChatState?
    ) throws

    func updateMessage(
        id: String,
        newID: String,
        to: BareJid,
        text: String
    ) throws

    func sendChatState(to: BareJid, chatState: ChatState) throws
    func sendPresence(show: ShowKind, status: String?) throws

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
    func proseClient(
        _ client: ProseClientProtocol,
        didReceivePresence presence: Presence
    )
}
