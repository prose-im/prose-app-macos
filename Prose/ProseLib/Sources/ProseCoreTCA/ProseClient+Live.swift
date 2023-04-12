//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

////
//// This file is part of prose-app-macos.
//// Copyright (c) 2022 Prose Foundation
////
//
// import AppDomain
// import AppKit
// import Combine
// import ComposableArchitecture
// import Foundation
// import ProseCoreFFI
// import Toolbox
// import UniformTypeIdentifiers
// import ProseBackend
//
// private extension Account {
//  static let placeholder = Account(jid: BareJid(node: "void", domain: "prose.org"), status:
//  .connected)
// }
//
// public extension ProseClient {
//  static func live<Client: ProseClientProtocol>(
//    provider: @escaping ProseClientProvider<Client>,
//    imageCache: AvatarImageCache,
//    date: @escaping () -> Date = Date.init,
//    uuid: @escaping () -> UUID = UUID.init
//  ) -> Self {
//    // Only one client/account for now.
//    var client: Client?
//    let delegate = Delegate(date: date, imageCache: imageCache)
//
//    func toggleReaction(
//      to: BareJid,
//      id: Message.ID,
//      reaction: Reaction
//    ) -> EffectPublisher<None, EquatableError> {
//      guard let client = client else {
//        return EffectPublisher(error: EquatableError(ProseClientError.notAuthenticated))
//      }
//
//      guard delegate.activeChats[to]?.containsMessage(id: id) == true else {
//        return EffectPublisher(error: EquatableError(ProseClientError.unknownMessageID))
//      }
//
//      do {
//        let jid = client.jid.bareJid
//        try delegate.activeChats[to]?.updateMessage(id: id) { message in
//          message.reactions.toggleReaction(reaction, for: jid)
//          try client.sendReactions(
//            Set(message.reactions.reactions(for: jid).map(\.rawValue)),
//            to: to,
//            messageId: message.id.rawValue
//          )
//        }
//      } catch {
//        return EffectPublisher(error: EquatableError(error))
//      }
//
//      return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
//    }
//
//    return ProseClient(
//      login: { jid, password in
//        delegate.account = .init(jid: jid, status: .connecting)
//        client = provider(
//          FullJid(node: jid.node, domain: jid.domain, resource: "macOS"),
//          delegate,
//          .main
//        )
//
//        do {
//          try client?.connect(credential: .password(password))
//        } catch {
//          return EffectPublisher(error: EquatableError(error))
//        }
//
//        return delegate.$account
//          .skipUntilConnected()
//          .handleEvents(receiveOutput: { _ in
//            try? client?.loadRoster()
//            try? client?.sendPresence(show: .chat, status: nil)
//          })
//          .map { _ in .none }
//          .eraseToEffect()
//      },
//      logout: { _ in
//        Empty(completeImmediately: true).eraseToEffect()
//      },
//      roster: {
//        delegate.$roster.map { roster in
//          if let jid = client?.jid {
//            return roster.appendingItemToFirstGroup(
//              .init(jid: jid.bareJid, subscription: .both)
//            )
//          }
//          return roster
//        }
//        .setFailureType(to: EquatableError.self)
//        .removeDuplicates()
//        .eraseToEffect()
//      },
//      activeChats: {
//        delegate.$activeChats
//          .setFailureType(to: EquatableError.self)
//          .removeDuplicates()
//          .eraseToEffect()
//      },
//      presence: {
//        delegate.$presences
//          .setFailureType(to: EquatableError.self)
//          .removeDuplicates()
//          .eraseToEffect()
//      },
//      userInfos: { jids in
//        delegate.$userInfos
//          .map { (userInfos: [BareJid: UserInfo]) in
//            userInfos.filter { jids.contains($0.key) }
//          }
//          .setFailureType(to: EquatableError.self)
//          .removeDuplicates()
//          .eraseToEffect()
//      },
//      incomingMessages: {
//        delegate.incomingMessages.eraseToEffect()
//      },
//      messagesInChat: { jid in
//        delegate.$activeChats
//          .map { $0[jid]?.messages ?? [] }
//          .setFailureType(to: EquatableError.self)
//          .removeDuplicates()
//          .eraseToEffect()
//      },
//      sendMessage: { to, body in
//        guard let client = client else {
//          return EffectPublisher(error: EquatableError(ProseClientError.notAuthenticated))
//        }
//
//        let messageID = Message.ID(rawValue: uuid().uuidString)
//
//        do {
//          try client.sendMessage(
//            id: messageID.rawValue,
//            to: to,
//            text: body,
//            chatState: .active
//          )
//        } catch {
//          return EffectPublisher(error: EquatableError(error))
//        }
//
//        let jid = JID(fullJid: client.jid)
//
//        let message = Message(
//          from: jid,
//          id: messageID,
//          kind: .chat,
//          body: body,
//          timestamp: date(),
//          isRead: true,
//          isEdited: false
//        )
//        delegate.activeChats[to, default: Chat(jid: to)].appendMessage(message)
//
//        return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
//      },
//      updateMessage: { to, id, body in
//        guard let client = client else {
//          return EffectPublisher(error: EquatableError(ProseClientError.notAuthenticated))
//        }
//
//        guard let messageToUpdate = delegate.activeChats[to]?.messages[id: id] else {
//          return EffectPublisher(error: EquatableError(ProseClientError.unknownMessageID))
//        }
//
//        do {
//          let newMessageID = Message.ID(rawValue: uuid().uuidString)
//
//          try client.updateMessage(
//            id: id.rawValue,
//            newId: newMessageID.rawValue,
//            to: to,
//            text: body
//          )
//
//          var updatedMessage = messageToUpdate
//          updatedMessage.isEdited = true
//          updatedMessage.body = body
//
//          delegate.activeChats[to]?.updateMessage(updatedMessage)
//        } catch {
//          return EffectPublisher(error: EquatableError(error))
//        }
//
//        return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
//      },
//      addReaction: { to, id, reaction in
//        guard let client = client else {
//          return EffectPublisher(error: EquatableError(ProseClientError.notAuthenticated))
//        }
//
//        guard delegate
//          .activeChats[to]?
//          .messages[id: id]?
//          .reactions[reaction]?
//          .contains(client.jid.bareJid) != true
//        else {
//          return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
//        }
//        return toggleReaction(to: to, id: id, reaction: reaction)
//      },
//      toggleReaction: { to, id, reaction in
//        toggleReaction(to: to, id: id, reaction: reaction)
//      },
//      retractMessage: { to, id in
//        guard let client = client else {
//          return EffectPublisher(error: EquatableError(ProseClientError.notAuthenticated))
//        }
//
//        guard delegate.activeChats[to]?.containsMessage(id: id) == true else {
//          return EffectPublisher(error: EquatableError(ProseClientError.unknownMessageID))
//        }
//
//        do {
//          try client.retractMessage(to: to, messageId: id.rawValue)
//          delegate.activeChats[to]?.removeMessage(id: id)
//        } catch {
//          return EffectPublisher(error: EquatableError(error))
//        }
//
//        return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
//      },
//      sendChatState: { to, kind in
//        guard let client = client else {
//          return EffectPublisher(error: EquatableError(ProseClientError.notAuthenticated))
//        }
//
//        do {
//          try client.sendChatState(to: to, chatState: kind.ffi)
//        } catch {
//          return EffectPublisher(error: EquatableError(error))
//        }
//
//        return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
//      },
//      sendPresence: { show, status in
//        guard let client = client else {
//          return EffectPublisher(error: EquatableError(ProseClientError.notAuthenticated))
//        }
//
//        do {
//          try client.sendPresence(show: show.ffi, status: status)
//        } catch {
//          return EffectPublisher(error: EquatableError(error))
//        }
//
//        return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
//      },
//      markMessagesReadInChat: { jid in
//        delegate.activeChats[jid]?.markMessagesRead()
//        return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
//      },
//      fetchPastMessagesInChat: { jid -> EffectPublisher<None, EquatableError> in
//        guard let client = client else {
//          return EffectPublisher(error: EquatableError(ProseClientError.notAuthenticated))
//        }
//
//        delegate.activeChats.removeValue(forKey: jid)
//
//        return Future { promise in
//          client.loadMessagesInChat(jid: jid, before: nil) { result, _ in
//            switch result {
//            case let .success(messages):
//              for var message in messages {
//                let messageWasSentByUs =
//                  message.message.from.node == client.jid.node &&
//                  message.message.from.domain == client.jid.domain
//
//                // Our messages don't have the `to` field set.
//                if messageWasSentByUs {
//                  message.message.to = jid
//                }
//
//                delegate.handleMessage(
//                  message.message,
//                  carbon: messageWasSentByUs ? .sent : .received,
//                  date: {
//                    (message.delay?.stamp)
//                      .map { Date(timeIntervalSince1970: Double($0)) } ?? date()
//                  }
//                )
//              }
//              promise(.success(None.none))
//            case let .failure(error):
//              promise(.failure(EquatableError(error)))
//            }
//          }
//        }.eraseToEffect()
//      },
//      setAvatarImage: { image in
//        guard let client = client else {
//          return EffectPublisher(error: EquatableError(ProseClientError.notAuthenticated))
//        }
//
//        let jid = client.jid.bareJid
//
//        return Deferred {
//          Future<Data, Error> { promise in
//            guard let jpgData = try? image
//              .prose_downsampled(maxPixelSize: 600)
//              .prose_jpegData(compressionQuality: 0.75)
//            else {
//              return promise(.failure(ProseClientError.invalidImage))
//            }
//            promise(.success(jpgData))
//          }
//        }
//        .subscribe(on: DispatchQueue.global())
//        .flatMap { (imageData: Data) in
//          client.setAvatarImage(image: XmppImage(
//            data: [UInt8](imageData),
//            mimeType: UTType.jpeg.identifier,
//            width: UInt32(truncatingIfNeeded: image.width),
//            height: UInt32(truncatingIfNeeded: image.height)
//          ))
//          .receive(on: DispatchQueue.global())
//          .tryMap { imageId in
//            try imageCache.cacheAvatarImage(jid, imageData, imageId)
//          }
//          .receive(on: DispatchQueue.main)
//          .map { cachedImageURL in
//            delegate.userInfos[jid, default: .init(jid: jid)].avatar = cachedImageURL
//          }
//        }
//        .mapError(EquatableError.init)
//        .mapVoidToNone()
//        .eraseToEffect()
//      }
//    )
//  }
// }
//
// private extension Publisher where Output == Account {
//  func skipUntilConnected() -> AnyPublisher<Account, EquatableError> {
//    self.tryDrop { account in
//      switch account.status {
//      case .disconnected, .connecting:
//        return true
//      case .connected:
//        return false
//      case let .error(error):
//        throw error
//      }
//    }
//    .mapError(EquatableError.init)
//    .eraseToAnyPublisher()
//  }
// }
//
// private extension Roster {
//  func appendingItemToFirstGroup(_ item: Roster.Group.Item) -> Roster {
//    let res = Roster(groups: self.groups.first.map { firstGroup in
//      var mutGroup = firstGroup
//      mutGroup.items.append(item)
//      return [mutGroup] + self.groups.suffix(from: 1)
//    } ?? [])
//    return res
//  }
// }
//
// enum ProseClientError: Error {
//  case connectionDidFail
//  case notAuthenticated
//  case unknownMessageID
//  case invalidImage
// }
//
// private final class Delegate: ProseClientDelegate, ObservableObject {
//  let date: () -> Date
//  let imageCache: AvatarImageCache
//
//  @Published var account = Account.placeholder
//  @Published var roster = Roster(groups: [])
//  @Published var activeChats = [BareJid: Chat]()
//  @Published var presences = [BareJid: Presence]()
//  @Published var userInfos = [BareJid: UserInfo]()
//
//  let incomingMessages = PassthroughSubject<Message, Never>()
//
//  private var loadUserInfosSubscription: AnyCancellable?
//
//  init(date: @escaping () -> Date, imageCache: AvatarImageCache) {
//    self.date = date
//    self.imageCache = imageCache
//  }
//
//  func proseClientDidConnect(_: ProseClientProtocol) {
//    self.account.status = .connected
//  }
//
//  func proseClient(_: ProseClientProtocol, connectionDidFailWith error: Error?) {
//    self.account.status = .error(EquatableError(error ?? ProseClientError.connectionDidFail))
//  }
//
//  func proseClient(
//    _ client: ProseClientProtocol,
//    didReceiveRoster roster: XmppRoster
//  ) {
//    let newRoster = Roster(roster: roster)
//    guard newRoster != self.roster else {
//      return
//    }
//    self.roster = newRoster
//
//    self.loadUserInfosSubscription?.cancel()
//
//    let jids = Set(
//      newRoster.groups.flatMap { $0.items.map(\.jid) } +
//        CollectionOfOne(client.jid.bareJid)
//    )
//    let newJids = jids.subtracting(self.userInfos.keys)
//
//    self.loadUserInfosSubscription = Publishers.MergeMany(
//      newJids.map { Self.loadUserInfo(jid: $0, client: client, imageCache: self.imageCache) }
//    )
//    .collect()
//    .receive(on: DispatchQueue.main)
//    .sink(
//      receiveCompletion: { _ in },
//      receiveValue: { userInfos in
//        let newUserInfos = Dictionary(
//          zip(userInfos.map(\.jid), userInfos),
//          uniquingKeysWith: { _, last in last }
//        )
//
//        self.userInfos.merge(newUserInfos, uniquingKeysWith: { _, last in last })
//      }
//    )
//  }
//
//  func proseClient(
//    _: ProseClientProtocol,
//    didReceiveMessage message: XmppMessage
//  ) {
//    self.handleMessage(message, carbon: .none, date: self.date)
//  }
//
//  func proseClient(
//    _: ProseClientProtocol,
//    didReceiveMessageCarbon message: XmppForwardedMessage
//  ) {
//    self.handleMessage(message.message, carbon: .received, date: self.date)
//  }
//
//  func proseClient(
//    _: ProseClientProtocol,
//    didReceiveSentMessageCarbon message: XmppForwardedMessage
//  ) {
//    self.handleMessage(message.message, carbon: .sent, date: self.date)
//  }
//
//  func proseClient(
//    _: ProseClientProtocol,
//    didReceivePresence presence: XmppPresence
//  ) {
//    if let jid = presence.from {
//      self.presences[jid] = .init(presence: presence, timestamp: self.date())
//    }
//  }
//
//  func proseClient(
//    _ client: ProseClientProtocol,
//    didReceivePresenceSubscriptionRequest from: BareJid
//  ) {
//    try? client.grantPresencePermissionToUser(jid: from)
//    try? client.addUserToRoster(jid: from, nickname: nil, groups: [])
//  }
//
//  func proseClient(
//    _: ProseClientProtocol,
//    didReceiveArchivingPreferences _: XmppmamPreferences
//  ) {}
// }
//
// private extension Delegate {
//  enum CarbonKind {
//    case sent
//    case received
//  }
//
//  func handleMessage(_ message: XmppMessage, carbon: CarbonKind?, date: () -> Date) {
//    // Roll all updates to our active chats into one. Otherwise downstream subscribers may
//    // receive multiple changes.
//    var activeChats = self.activeChats
//    defer {
//      self.activeChats = activeChats
//    }
//
//    let from: BareJid = {
//      switch carbon {
//      case .none, .received:
//        return message.from
//      case .sent:
//        return message.to
//            .expect("A received message carbon sent by us should have a receiver ('to') set.")
//      }
//    }()
//
//    if message.replace == nil, let message = Message(message: message, timestamp: date()) {
//      activeChats[from, default: Chat(jid: from)].appendMessage(message)
//
//      // We don't publish messages that were sent or received by us on other devices
//      // as incoming messages.
//      if carbon == nil {
//        self.incomingMessages.send(message)
//      }
//    }
//
//    if let chatState = message.chatState, carbon != .sent {
//      activeChats[from, default: Chat(jid: from)].participantStates[from] =
//        .init(state: chatState, timestamp: date())
//    }
//
//    if let reactions = message.reactions {
//      activeChats[from]?.updateMessage(id: Message.ID(rawValue: reactions.id)) { messageToUpdate in
//        messageToUpdate.reactions.setReactions(
//          reactions.reactions.map(Reaction.init(rawValue:)),
//          for: message.from
//        )
//      }
//    }
//
//    if let fastening = message.fastening, fastening.retract {
//      activeChats[from]?.removeMessage(id: Message.ID(rawValue: fastening.id))
//    }
//
//    if
//      let messageId = message.replace,
//      let body = message.body,
//      let oldMessage = activeChats[from]?.messages[id: Message.ID(rawValue: messageId)]
//    {
//      var message = oldMessage
//      message.isEdited = true
//      message.body = body
//      activeChats[from]?.updateMessage(message)
//    }
//  }
//
//  static func loadUserInfo(
//    jid: BareJid,
//    client: ProseClientProtocol,
//    imageCache: AvatarImageCache
//  ) -> AnyPublisher<UserInfo, Error> {
//    client.loadLatestAvatarMetadata(jid: jid)
//      .flatMap { (metadata: XmppAvatarMetadataInfo?) -> AnyPublisher<URL?, Error> in
//        guard let metadata = metadata else {
//          return Just(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
//        }
//
//        if let url = imageCache.cachedURLForAvatarImageWithID(jid, metadata.id) {
//          return Just(url).setFailureType(to: Error.self).eraseToAnyPublisher()
//        }
//
//        return client.loadAvatarImage(jid: jid, imageId: metadata.id)
//          .receive(on: DispatchQueue.global())
//          .tryMap { (avatarData: XmppAvatarData?) in
//            try avatarData.flatMap { try imageCache.cacheAvatarImage(jid, Data($0.data), $0.sha1)
//            }
//          }
//          .eraseToAnyPublisher()
//      }
//      .map { avatarURL in UserInfo(jid: jid, avatar: avatarURL) }
//      .eraseToAnyPublisher()
//  }
// }
