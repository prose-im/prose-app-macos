//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

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
        delegate.$roster.map { roster in
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
      incomingMessages: {
        delegate.incomingMessages.eraseToEffect()
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

        guard let messageToUpdate = delegate.activeChats[to]?.messages[id: id] else {
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

          var updatedMessage = messageToUpdate
          updatedMessage.id = newMessageID
          updatedMessage.isEdited = true
          updatedMessage.body = body

          delegate.activeChats[to]?.replaceMessage(id: id, with: updatedMessage)
        } catch {
          return Effect(error: EquatableError(error))
        }

        return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
      },
      addReaction: { to, id, reaction in
        guard let client = client else {
          return Effect(error: EquatableError(ProseClientError.notAuthenticated))
        }

        guard delegate.activeChats[to]?.containsMessage(id: id) == true else {
          return Effect(error: EquatableError(ProseClientError.unknownMessageID))
        }

        let jid = JID(bareJid: client.jid)

        #warning("TODO: Update message using the client")

        delegate.activeChats[to]?.updateMessage(id: id) { message in
          message.reactions.addReaction(reaction, for: jid)
        }

        return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
      },
      toggleReaction: { to, id, reaction in
        guard let client = client else {
          return Effect(error: EquatableError(ProseClientError.notAuthenticated))
        }

        guard delegate.activeChats[to]?.containsMessage(id: id) == true else {
          return Effect(error: EquatableError(ProseClientError.unknownMessageID))
        }

        let jid = JID(bareJid: client.jid)

        #warning("TODO: Update message using the client")

        delegate.activeChats[to]?.updateMessage(id: id) { message in
          message.reactions.toggleReaction(reaction, for: jid)
        }

        return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
      },
      retractMessage: { _ in
        fatalError("Not implemented yet.")
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

  let incomingMessages = PassthroughSubject<Message, Never>()

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
    didReceiveRoster roster: XmppRoster
  ) {
    self.roster = Roster(roster: roster)
  }

  func proseClient(
    _: ProseClientProtocol,
    didReceiveMessage message: XmppMessage
  ) {
    if message.replace == nil, let message = Message(message: message, timestamp: self.date()) {
      self.activeChats[message.from, default: Chat(jid: message.from)].appendMessage(message)
      self.incomingMessages.send(message)
    }

    let jid = JID(bareJid: message.from)

    if let chatState = message.chatState {
      self.activeChats[jid, default: Chat(jid: jid)].participantStates[jid] =
        .init(state: chatState, timestamp: self.date())
    }

    if
      let replace = message.replace,
      let newID = message.id,
      let body = message.body,
      let oldMessage = self.activeChats[jid]?.messages[id: Message.ID(rawValue: replace)]
    {
      var message = oldMessage
      message.id = Message.ID(rawValue: newID)
      message.isEdited = true
      message.body = body
      self.activeChats[jid]?.replaceMessage(id: oldMessage.id, with: message)
    }
  }

  func proseClient(
    _: ProseClientProtocol,
    didReceivePresence presence: XmppPresence
  ) {
    if let jid = presence.from.map(JID.init) {
      self.presences[jid] = .init(presence: presence, timestamp: self.date())
    }
  }

  func proseClient(
    _ client: ProseClientProtocol,
    didReceivePresenceSubscriptionRequest from: BareJid
  ) {
    try? client.grantPresencePermissionToUser(jid: from)
    try? client.addUserToRoster(jid: from, nickname: nil, groups: [])
  }

  func proseClient(
    _: ProseClientProtocol,
    didReceiveArchivingPreferences _: XmppmamPreferences
  ) {}
}
