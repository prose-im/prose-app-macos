import Foundation
import ProseCoreClientFFI

enum ProseClientError: Error {
    case missingCredentials
}

public final class ProseClient {
    public private(set) weak var delegate: ProseClientDelegate?

    private let client = ProseCoreClientFFI.Client()

    /// When `true`, we're either already connected or in the midst of a connection attempt.
    private var isConnected = false

    // Temporarily save these here until the core lib provides two methods for authentication
    // and connection as well.
    public private(set) var jid: String?

    private var credential: Credential?

    public init(delegate: ProseClientDelegate) {
        self.delegate = delegate
    }

    public func authenticate(jid: String, with credential: Credential) throws {
        self.jid = jid
        self.credential = credential
    }

    public func connect() throws {
        guard !self.isConnected else {
            // Nothing to do.
            return
        }

        guard let jid = self.jid, case let .password(password) = self.credential else {
            throw ProseClientError.missingCredentials
        }

        do {
            self.isConnected = true
            // The core lib returns a (parsed) BareJid. Should we pass that to our client?
            // Should probably happen in the `authenticate(jid:with:)` call already or we'd provide
            // a helper function to validate Jids and only accept a parsed Jid.
            _ = try self.client.connect(jid: jid, password: password, observer: self)
        } catch {
            self.isConnected = false
            throw error
        }
    }

    public func disconnect() {
        // Hah. We're always on!
    }

    public func sendMessage(to jid: String, text: String) throws {
        try self.withAccount { accountJid in
            self.client.sendMessage(accountJid: accountJid, receiverJid: jid, body: text)
        }
    }

    public func loadRoster() throws {
        try self.withAccount { accountJid in
            self.client.loadRoster(accountJid: accountJid)
        }
    }
}

private extension ProseClient {
    // The core lib really should save the account JID itself in the next iteration. For now we
    // have this crutch…
    func withAccount<T>(_ handler: (String) throws -> T) throws -> T {
        guard let jid = self.jid else {
            throw ProseClientError.missingCredentials
        }
        return try handler(jid)
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
}
