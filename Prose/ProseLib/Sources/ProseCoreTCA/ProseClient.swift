import ComposableArchitecture
import Foundation
import Toolbox

public struct Account: Hashable {
    public enum Status: Hashable {
        case connecting
        case connected
        case error(EquatableError)
    }

    public var jid: JID
    public var status: Status
}

public struct ProseClient {
    public var login: (_ jid: JID, _ password: String) -> Effect<None, EquatableError>
    public var logout: (_ jid: JID) -> Effect<None, Never>

    public var roster: () -> Effect<Roster, Never>

    public var messagesInChat: (_ with: JID) -> Effect<[Message], Never>
    public var sendMessage: (_ to: JID, _ body: String) -> Effect<None, EquatableError>
    
    public var markMessagesReadInChat: (_ jid: JID) -> Effect<None, Never>
}
