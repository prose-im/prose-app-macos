import Foundation
import ProseCore
import ProseCoreClientFFI

final class ProseMockClient: ProseClientProtocol {
    let jid: BareJid
    let delegate: ProseClientDelegate

    var impl = ProseMockClientImpl()

    init(jid: BareJid, delegate: ProseCore.ProseClientDelegate) {
        self.jid = jid
        self.delegate = delegate
    }

    func connect(credential: ProseCore.Credential) throws {
        try self.impl.connect(credential)
    }

    func disconnect() {
        self.impl.disconnect()
    }

    func sendMessage(id: String, to: BareJid, text: String, chatState: ChatState?) throws {
        try self.impl.sendMessage(id, to, text, chatState)
    }

    func updateMessage(id: String, newID: String, to: BareJid, text: String) throws {
        try self.impl.updateMessage(id, newID, to, text)
    }

    func sendChatState(to: BareJid, chatState: ChatState) throws {
        try self.impl.sendChatState(to, chatState)
    }

    func sendPresence(show: ShowKind, status: String?) throws {
        try self.impl.sendPresence(show, status)
    }

    func loadRoster() throws {
        try self.impl.loadRoster()
    }
}

extension ProseMockClient {
    static func provider(
        _ handler: @escaping (ProseMockClient) -> Void
    ) -> ProseClientProvider<ProseMockClient> {
        { jid, delegate in
            let client = ProseMockClient(jid: jid, delegate: delegate)
            handler(client)
            return client
        }
    }
}

struct ProseMockClientImpl {
    var connect: (ProseCore.Credential) throws -> Void = { _ in }
    var disconnect: () -> Void = {}
    var sendMessage: (String, BareJid, String, ChatState?) throws -> Void = { _, _, _, _ in }
    var updateMessage: (String, String, BareJid, String) throws -> Void = { _, _, _, _ in }
    var sendChatState: (BareJid, ChatState) throws -> Void = { _, _ in }
    var sendPresence: (ShowKind, String?) throws -> Void = { _, _ in }
    var loadRoster: () throws -> Void = {}
}
