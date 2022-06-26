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
                delegate.account = .init(jid: jid, status: .connecting)
                client = provider(jid.bareJid, delegate)

                do {
                    try client?.connect(credential: .password(password))
                } catch {
                    return Effect(error: EquatableError(error))
                }

                return delegate.$account
                    .skipUntilConnected()
                    .handleEvents(receiveOutput: { _ in
                        try? client?.loadRoster()
                        try? client?.sendPresence(show: .chat, status: nil)
                    })
                    .map { _ in .none }
                    .eraseToEffect()
            },
            logout: { _ in
                Empty(completeImmediately: true).eraseToEffect()
            },
            roster: {
                return delegate.$roster.map { roster in
                    if let jid = client?.jid {
                      return roster.appendingItemToFirstGroup(
                          .init(jid: JID(bareJid: jid), subscription: .both)
                      )
                    }
                    return roster
                }
                .setFailureType(to: EquatableError.self)
                .removeDuplicates()
                .eraseToEffect()
            },
            activeChats: {
                delegate.$activeChats
                    .setFailureType(to: EquatableError.self)
                    .removeDuplicates()
                    .eraseToEffect()
            },
            presence: {
                delegate.$presences
                    .setFailureType(to: EquatableError.self)
                    .removeDuplicates()
                    .eraseToEffect()
            },
            messagesInChat: { jid in
                delegate.$activeChats
                    .map { $0[jid]?.messages ?? [] }
                    .setFailureType(to: EquatableError.self)
                    .removeDuplicates()
                    .eraseToEffect()
            },
            sendMessage: { to, body in
                guard let client = client else {
                    return Effect(error: EquatableError(ProseClientError.notAuthenticated))
                }

                let messageID = Message.ID(rawValue: uuid().uuidString)

                do {
                    try client.sendMessage(
                        id: messageID.rawValue,
                        to: to.bareJid,
                        text: body,
                        chatState: .active
                    )
                } catch {
                    return Effect(error: EquatableError(error))
                }

                let jid = JID(bareJid: client.jid)

                let message = Message(
                    from: jid,
                    id: messageID,
                    kind: .chat,
                    body: body,
                    timestamp: date(),
                    isRead: true,
                    isEdited: false
                )
                delegate.activeChats[to, default: Chat(jid: to)].appendMessage(message)

                return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
            },
            updateMessage: { to, id, body in
                guard let client = client else {
                    return Effect(error: EquatableError(ProseClientError.notAuthenticated))
                }

                guard delegate.activeChats[to]?.containsMessage(id: id) == true else {
                    return Effect(error: EquatableError(ProseClientError.unknownMessageID))
                }

                do {
                    let newMessageID = Message.ID(rawValue: uuid().uuidString)

                    try client.updateMessage(
                        id: id.rawValue,
                        newID: newMessageID.rawValue,
                        to: to.bareJid,
                        text: body
                    )

                    delegate.activeChats[to]?.updateMessage(id: id) { message in
                        message.id = newMessageID
                        message.isEdited = true
                        message.body = body
                    }
                } catch {
                    return Effect(error: EquatableError(error))
                }

                return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
            },
            sendChatState: { to, kind in
                guard let client = client else {
                    return Effect(error: EquatableError(ProseClientError.notAuthenticated))
                }

                do {
                    try client.sendChatState(to: to.bareJid, chatState: kind.ffi)
                } catch {
                    return Effect(error: EquatableError(error))
                }

                return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
            },
            sendPresence: { show, status in
                guard let client = client else {
                    return Effect(error: EquatableError(ProseClientError.notAuthenticated))
                }

                do {
                    try client.sendPresence(show: show.ffi, status: status)
                } catch {
                    return Effect(error: EquatableError(error))
                }

                return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
            },
            markMessagesReadInChat: { jid in
                delegate.activeChats[jid]?.markMessagesRead()
                return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
            }
        )
    }
}

private extension Publisher where Output == Account {
    func skipUntilConnected() -> AnyPublisher<Account, EquatableError> {
        self.tryDrop { account in
            switch account.status {
            case .connecting:
                return true
            case .connected:
                return false
            case let .error(error):
                throw error
            }
        }
        .mapError(EquatableError.init)
        .eraseToAnyPublisher()
    }
}

private extension Roster {
    func appendingItemToFirstGroup(_ item: Roster.Group.Item) -> Roster {
        let res = Roster(groups: self.groups.first.map { firstGroup in
            var mutGroup = firstGroup
            mutGroup.items.append(item)
            return [mutGroup] + self.groups.suffix(from: 1)
        } ?? [])
        return res
    }
}

enum ProseClientError: Error {
    case connectionDidFail
    case notAuthenticated
    case unknownMessageID
}

private final class Delegate: ProseClientDelegate, ObservableObject {
    let date: () -> Date

    @Published var account = Account.placeholder
    @Published var roster = Roster(groups: [])
    @Published var activeChats = [JID: Chat]()
    @Published var presences = [JID: Presence]()

    init(date: @escaping () -> Date) {
        self.date = date
    }

    func proseClientDidConnect(_: ProseClientProtocol) {
        self.account.status = .connected
    }

    func proseClient(_: ProseClientProtocol, connectionDidFailWith error: Error?) {
        self.account.status = .error(EquatableError(error ?? ProseClientError.connectionDidFail))
    }

    func proseClient(
        _: ProseClientProtocol,
        didReceiveRoster roster: ProseCoreClientFFI.Roster
    ) {
        self.roster = Roster(roster: roster)
    }

    func proseClient(
        _: ProseClientProtocol,
        didReceiveMessage message: ProseCoreClientFFI.Message
    ) {
        if message.replace == nil, let message = Message(message: message, timestamp: self.date()) {
            self.activeChats[message.from, default: Chat(jid: message.from)].appendMessage(message)
        }

        let jid = JID(bareJid: message.from)

        if let chatState = message.chatState {
            self.activeChats[jid, default: Chat(jid: jid)].participantStates[jid] =
                .init(state: chatState, timestamp: self.date())
        }

        if let replace = message.replace, let newID = message.id, let body = message.body {
            self.activeChats[jid]?.updateMessage(id: Message.ID(rawValue: replace)) { message in
                message.id = Message.ID(rawValue: newID)
                message.isEdited = true
                message.body = body
            }
        }
    }

    func proseClient(
        _: ProseClientProtocol,
        didReceivePresence presence: ProseCoreClientFFI.Presence
    ) {
        if let jid = presence.from.map(JID.init) {
            self.presences[jid] = .init(presence: presence, timestamp: self.date())
        }
    }
}
