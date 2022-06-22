import ComposableArchitecture
import Foundation
import SharedModels

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
}
