import Foundation
import ProseCoreClientFFI

enum ProseClientError: Error {
    case unsupportedCredentials
}

public final class ProseClient {
    public private(set) weak var delegate: ProseClientDelegate?

    private let client: ProseCoreClientFFI.Client

    /// When `true`, we're either already connected or in the midst of a connection attempt.
    private var isConnected = false

    public var jid: BareJid {
        self.client.jid()
    }

    private var credential: Credential?

    public init(jid: BareJid, delegate: ProseClientDelegate) {
        self.client = .init(jid: jid)
        self.delegate = delegate
        
        if ProcessInfo.processInfo.environment["PROSE_CORE_LOG_ENABLED"] == "1" {
            enableLogging()
        }
    }

    public func connect(credential: Credential) throws {
        guard !self.isConnected else {
            // Nothing to do.
            return
        }

        guard case let .password(password) = credential else {
            throw ProseClientError.unsupportedCredentials
        }

        self.isConnected = true
        try self.client.connect(password: password, observer: self)
    }

    public func disconnect() {
        // Hah. We're always on!
    }

    public func sendMessage(to jid: BareJid, text: String) throws {
        self.client.sendMessage(id: UUID().uuidString, to: jid, body: text, chatState: nil)
    }

    public func loadRoster() throws {
        self.client.loadRoster()
    }
}

public protocol ProseClientDelegate: AnyObject {
    func proseClientDidConnect(_ client: ProseClient)
    func proseClient(_ client: ProseClient, connectionDidFailWith error: Error?)

    func proseClient(_ client: ProseClient, didReceiveRoster roster: ProseCoreClientFFI.Roster)
    func proseClient(_ client: ProseClient, didReceiveMessage message: ProseCoreClientFFI.Message)
}

extension ProseClient: AccountObserver {
    public func didConnect() {
        self.delegate?.proseClientDidConnect(self)
    }

    public func didDisconnect() {
        self.isConnected = false
        // We need to receive an error here from the core lib. Unfortunately the core lib itself
        // doesn't receive an error for invalid credentials from libstrophe at this point.
        self.delegate?.proseClient(self, connectionDidFailWith: nil)
    }

    public func didReceiveMessage(message: ProseCoreClientFFI.Message) {
        self.delegate?.proseClient(self, didReceiveMessage: message)
    }

    public func didReceiveRoster(roster: ProseCoreClientFFI.Roster) {
        self.delegate?.proseClient(self, didReceiveRoster: roster)
    }

    public func didReceivePresence(presence _: Presence) {}
}
