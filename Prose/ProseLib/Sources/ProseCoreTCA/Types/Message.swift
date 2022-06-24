import Foundation
import ProseCoreClientFFI

public enum MessageKind: Equatable {
    case chat
    case error
    case groupChat
    case headline
    case normal
}

public enum MessageID: Hashable {
    case serverAssigned(String)
    case selfAssigned(UUID)
}

public struct Message: Equatable, Identifiable {
    public var from: JID
    public var id: MessageID
    public var kind: MessageKind?
    public var body: String
    public var timestamp: Date
    public var isRead: Bool

    public init(
        from: JID,
        id: MessageID,
        kind: MessageKind?,
        body: String,
        timestamp: Date,
        isRead: Bool
    ) {
        self.from = from
        self.id = id
        self.kind = kind
        self.body = body
        self.timestamp = timestamp
        self.isRead = isRead
    }
}

extension Message {
    init?(message: ProseCoreClientFFI.Message, timestamp: Date) {
        // We'll discard messages with empty bodies and messages without ids. Ids don't seem to be
        // specified in the XMPP spec but our current server adds them, unless you send a message to
        // yourself.
        guard let body = message.body, let id = message.id else {
            return nil
        }

        self.init(
            from: JID(bareJid: message.from),
            id: .serverAssigned(id),
            kind: message.kind.map(MessageKind.init),
            body: body,
            timestamp: timestamp,
            isRead: false
        )
    }
}

extension MessageKind {
    init(kind: ProseCoreClientFFI.MessageKind) {
        switch kind {
        case .chat:
            self = .chat
        case .error:
            self = .error
        case .groupchat:
            self = .groupChat
        case .headline:
            self = .headline
        case .normal:
            self = .normal
        @unknown default:
            fatalError("Unknown MessageKind \(kind)")
        }
    }
}
