import Combine
import ComposableArchitecture
import Foundation
@_implementationOnly import ProseCore
@_implementationOnly import ProseCoreClientFFI
import SharedModels

private extension Account {
    static let placeholder = Account(jid: "void@prose.org", status: .connected)
}

public extension ProseClient {
    static var live: Self = {
        // Only one client/account for now.
        var client: ProseCore.ProseClient?
        var delegate = Delegate()

        return ProseClient(
            login: { jid, password in
                delegate.account.value = .init(jid: jid, status: .connecting)
                client = .init(delegate: delegate)

                do {
                    try client?.authenticate(jid: jid.rawValue, with: .password(password))
                    try client?.connect()
                } catch {
                    return Effect(error: EquatableError(error))
                }

                return delegate.account
                    .tryDrop { account in
                        switch account.status {
                        case .connecting:
                            return true
                        case .connected:
                            return false
                        case let .error(error):
                            throw error
                        }
                    }
                    .handleEvents(receiveOutput: { _ in
                        try? client?.loadRoster()
                    })
                    .mapError(EquatableError.init)
                    .map { _ in .none }
                    .eraseToEffect()
            },
            logout: { _ in
                Empty(completeImmediately: true).eraseToEffect()
            },
            roster: {
                delegate.roster.eraseToEffect()
            }
        )
    }()
}

enum ConnectionError: Error {
    case connectionDidFail
}

private final class Delegate: ProseClientDelegate {
    let account = CurrentValueSubject<Account, Never>(.placeholder)
    let roster = CurrentValueSubject<Roster, Never>(.init(groups: []))

    func proseClientDidConnect(_: ProseCore.ProseClient) {
        self.account.value.status = .connected
    }

    func proseClient(_: ProseCore.ProseClient, connectionDidFailWith error: Error?) {
        self.account.value.status =
            .error(EquatableError(error ?? ConnectionError.connectionDidFail))
    }

    func proseClient(
        _: ProseCore.ProseClient,
        didReceiveRoster roster: ProseCoreClientFFI.Roster
    ) {
        self.roster.value = Roster(roster: roster)
    }

    func proseClient(
        _: ProseCore.ProseClient,
        didReceiveMessage _: ProseCoreClientFFI.Message
    ) {}
}
