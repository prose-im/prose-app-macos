import Combine
import ComposableArchitecture
import Foundation
import ProseCore
import ProseCoreClientFFI
import Toolbox

private extension Account {
    static let placeholder = Account(jid: try! .init(string: "void@prose.org"), status: .connected)
}

public extension ProseClient {
    static func live<Client: ProseClientProtocol>(
        provider: @escaping ProseClientProvider<Client>,
        date: @escaping () -> Date = Date.init,
        uuid: @escaping () -> UUID = UUID.init
    ) -> Self {
        // Only one client/account for now.
        var client: Client?
        let delegate = Delegate(date: date)

        return ProseClient(
            login: { jid, password in
                delegate.account.value = .init(jid: jid, status: .connecting)
                client = provider(jid.bareJid, delegate)

                do {
                    try client?.connect(credential: .password(password))
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
                Publishers.CombineLatest(
                    delegate.roster,
                    delegate.chats
                ).map { roster, chats -> Roster in
                    // Append our own JID to each group, so that we can chat with
                    // ourselves (via a second IM).
                    if let jid = client?.jid {
                        return Roster(groups: roster.groups.map { group in
                            var mutGroup = group
                            mutGroup.items.append(
                                .init(
                                    jid: JID(bareJid: jid),
                                    subscription: .both
                                )
                            )
                            return mutGroup
                        })
                    }
                    return roster
                }
                .removeDuplicates()
                .eraseToEffect()
            },
            messagesInChat: { jid in
                delegate.chats
                    .map { $0[jid]?.messages ?? [] }
                    .removeDuplicates()
                    .eraseToEffect()
            },
            sendMessage: { to, body in
                guard let client = client else {
                    return Effect(error: EquatableError(ProseClientError.notAuthenticated))
                }

                do {
                    try client.sendMessage(to: to.bareJid, text: body)
                } catch {
                    return Effect(error: EquatableError(error))
                }

                let message = Message(
                    from: JID(bareJid: client.jid),
                    id: .selfAssigned(uuid()),
                    kind: .chat,
                    body: body,
                    timestamp: date(),
                    isRead: true
                )
                delegate.chats.value[to, default: Chat()].appendMessage(message)

                return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
            },
            markMessagesReadInChat: { jid in
                .fireAndForget {
                    delegate.chats.value[jid]?.markMessagesRead()
                }
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
    let chats = CurrentValueSubject<[JID: Chat], Never>([:])

    init(date: @escaping () -> Date) {
        self.date = date
    }

    func proseClientDidConnect(_: ProseClientProtocol) {
        self.account.value.status = .connected
    }

    func proseClient(_: ProseClientProtocol, connectionDidFailWith error: Error?) {
        self.account.value.status =
            .error(EquatableError(error ?? ProseClientError.connectionDidFail))
    }

    func proseClient(
        _: ProseClientProtocol,
        didReceiveRoster roster: ProseCoreClientFFI.Roster
    ) {
        self.roster.value = Roster(roster: roster)
    }

    func proseClient(
        _: ProseClientProtocol,
        didReceiveMessage message: ProseCoreClientFFI.Message
    ) {
        if let message = Message(message: message, timestamp: self.date()) {
            self.chats.value[message.from, default: Chat()].appendMessage(message)
        }
    }
}

private struct Chat: Equatable {
    private(set) var messages = [Message]()
    private(set) var numberOfUnreadMessages = 0

    mutating func appendMessage(_ message: Message) {
        self.messages.append(message)
        if !message.isRead {
            self.numberOfUnreadMessages += 1
        }
    }

    mutating func markMessagesRead() {
        self.messages.indices.forEach { idx in
            self.messages[idx].isRead = true
        }
        self.numberOfUnreadMessages = 0
    }
}
