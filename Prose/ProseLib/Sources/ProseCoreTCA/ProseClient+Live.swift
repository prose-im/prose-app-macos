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
    static func live(
        date: @escaping () -> Date = Date.init,
        uuid: @escaping () -> UUID = UUID.init
    ) -> Self {
        // Only one client/account for now.
        var client: ProseCore.ProseClient?
        let delegate = Delegate(date: date)

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
                delegate.roster
                    .map { roster in
                        // Append our own JID to each group, so that we can chat with
                        // ourselves (via a second IM).
                        if let jid = client?.jid {
                            return Roster(groups: roster.groups.map { group in
                                var mutGroup = group
                                mutGroup.items.append(
                                    .init(jid: JID(rawValue: jid), subscription: .both)
                                )
                                return mutGroup
                            })
                        }
                        return roster
                    }
                    .eraseToEffect()
            },
            messagesInChat: { jid in
                delegate.chats
                    .map { $0[jid] ?? [] }
                    .eraseToEffect()
            },
            sendMessage: { to, body in
                guard
                    let client = client,
                    let from = client.jid.map(JID.init(rawValue:))
                else {
                    return Effect(error: EquatableError(ProseClientError.notAuthenticated))
                }

                do {
                    try client.sendMessage(to: to.jidString, text: body)
                } catch {
                    return Effect(error: EquatableError(error))
                }

                let message = Message(
                    from: from,
                    id: .selfAssigned(uuid()),
                    body: body,
                    timestamp: date()
                )
                delegate.chats.value[to, default: []].append(message)

                return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
            }
        )
    }
}

enum ProseClientError: Error {
    case connectionDidFail
    case notAuthenticated
}

private final class Delegate: ProseClientDelegate {
    let date: () -> Date

    let account = CurrentValueSubject<Account, Never>(.placeholder)
    let roster = CurrentValueSubject<Roster, Never>(.init(groups: []))
    let chats = CurrentValueSubject<[JID: [Message]], Never>([:])

    init(date: @escaping () -> Date) {
        self.date = date
    }

    func proseClientDidConnect(_: ProseCore.ProseClient) {
        self.account.value.status = .connected
    }

    func proseClient(_: ProseCore.ProseClient, connectionDidFailWith error: Error?) {
        self.account.value.status =
            .error(EquatableError(error ?? ProseClientError.connectionDidFail))
    }

    func proseClient(
        _: ProseCore.ProseClient,
        didReceiveRoster roster: ProseCoreClientFFI.Roster
    ) {
        self.roster.value = Roster(roster: roster)
    }

    func proseClient(
        _: ProseCore.ProseClient,
        didReceiveMessage message: ProseCoreClientFFI.Message
    ) {
        if let message = Message(message: message, timestamp: self.date()) {
            self.chats.value[message.from, default: []].append(message)
        }
    }
}
