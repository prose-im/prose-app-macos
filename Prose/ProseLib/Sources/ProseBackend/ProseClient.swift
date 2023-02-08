//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Combine
import Foundation
import ProseCore

enum ProseClientError: Error {
  case unsupportedCredentials
}

extension ProseClient: ConnectionHandler {
  public func connectionStatusDidChange(event: ConnectionEvent) {
    switch event {
    case .connect:
      print("Connected")
    case .disconnect(let error):
      print("Disconnected. Error?", error.localizedDescription)
    }
  }
}

public final class ProseClient: ProseClientProtocol {
  public private(set) weak var delegate: ProseClientDelegate?

  private let client: ProseCore.XmppClient
  private let delegateQueue: DispatchQueue

  /// When `true`, we're either already connected or in the midst of a connection attempt.
  private var isConnected = false
  private var loadMessagesCompletionHandlers = [String: LoadMessagesCompletionHandler]()
  private var loadAvatarMetadataCompletionHandlers =
    [String: (Result<XmppAvatarMetadataInfo?, Error>) -> Void]()
  private var loadAvatarImageCompletionHandlers =
    [String: (Result<XmppAvatarData?, Error>) -> Void]()
  private var setAvatarImageCompletionHandlers = [String: (Result<ImageId, Error>) -> Void]()

  public var jid: FullJid {
    self.client.jid()
  }

  private var credential: Credential?

  public init(jid: FullJid, delegate: ProseClientDelegate, delegateQueue: DispatchQueue) {
    self.client = .init(jid: jid)
    self.delegate = delegate
    self.delegateQueue = delegateQueue

    if ProcessInfo.processInfo.environment["PROSE_CORE_LOG_ENABLED"] == "1" {
      enableLogging()
    }
  }

  public func connect(credential: Credential) throws {
    guard !self.isConnected else {
      // Nothing to do.
      return
    }

    guard case let .password(password) = credential else {
      throw ProseClientError.unsupportedCredentials
    }

    self.isConnected = true
    try self.client.connect(password: password, handler: self)
  }

  public func disconnect() {
    // Hah. We're always on!
  }

  public func sendMessage(
    id: String,
    to: BareJid,
    text: String,
    chatState: XmppChatState?
  ) throws {
    try self.client.sendMessage(id: id, to: to, body: text, chatState: chatState)
  }

  public func updateMessage(
    id: String,
    newId: String,
    to: BareJid,
    text: String
  ) throws {
    try self.client.updateMessage(id: id, newId: newId, to: to, body: text)
  }

  public func sendChatState(to: BareJid, chatState: XmppChatState) throws {
    try self.client.sendChatState(to: to, chatState: chatState)
  }

  public func sendPresence(show: XmppShowKind, status: String?) throws {
    try self.client.sendPresence(show: show, status: status)
  }

  public func loadRoster() throws {
    try self.client.loadRoster()
  }

  public func loadMessagesInChat(
    jid: BareJid,
    before: MessageId?,
    completion: @escaping LoadMessagesCompletionHandler
  ) {
    let requestId = UUID().uuidString
    self.loadMessagesCompletionHandlers[requestId] = completion

    do {
      try self.client.loadMessagesInChat(requestId: requestId, jid: jid, before: before)
    } catch {
      self.loadMessagesCompletionHandlers[requestId] = nil
      completion(.failure(error), false)
    }
  }

  public func sendReactions(_ reactions: Set<String>, to: BareJid, messageId: MessageId) throws {
    try self.client.sendReactions(id: messageId, to: to, reactions: Array(reactions))
  }

  public func retractMessage(to: BareJid, messageId: MessageId) throws {
    try self.client.retractMessage(id: messageId, to: to)
  }

  public func addUserToRoster(jid: BareJid, nickname: String?, groups: Set<String>) throws {
    try self.client.addUserToRoster(jid: jid, nickname: nickname, groups: Array(groups))
  }

  public func removeUserAndUnsubscribeFromPresence(jid: BareJid) throws {
    try self.client.removeUserAndUnsubscribeFromPresence(jid: jid)
  }

  public func subscribeToUserPresence(jid: BareJid) throws {
    try self.client.subscribeToUserPresence(jid: jid)
  }

  public func unsubscribeFromUserPresence(jid: BareJid) throws {
    try self.client.unsubscribeFromUserPresence(jid: jid)
  }

  public func grantPresencePermissionToUser(jid: BareJid) throws {
    try self.client.grantPresencePermissionToUser(jid: jid)
  }

  public func revokeOrRejectPresencePermissionFromUser(jid: BareJid) throws {
    try self.client.revokeOrRejectPresencePermissionFromUser(jid: jid)
  }

  public func setAvatarImage(image: XmppImage) -> AnyPublisher<ImageId, Error> {
    Deferred {
      Future { promise in
        let requestId = UUID().uuidString

        self.setAvatarImageCompletionHandlers[requestId] = { result in
          promise(result)
        }

        do {
          try self.client.setAvatarImage(requestId: requestId, image: image)
        } catch {
          self.setAvatarImageCompletionHandlers[requestId] = nil
          promise(.failure(error))
        }
      }
    }
    .subscribe(on: self.delegateQueue)
    .eraseToAnyPublisher()
  }

  public func loadLatestAvatarMetadata(
    jid: BareJid
  ) -> AnyPublisher<XmppAvatarMetadataInfo?, Error> {
    Deferred {
      Future { promise in
        let requestId = UUID().uuidString

        self.loadAvatarMetadataCompletionHandlers[requestId] = { result in
          promise(result)
        }

        do {
          try self.client.loadLatestAvatarMetadata(requestId: requestId, from: jid)
        } catch {
          self.loadAvatarMetadataCompletionHandlers[requestId] = nil
          promise(.failure(error))
        }
      }
    }
    .subscribe(on: self.delegateQueue)
    .eraseToAnyPublisher()
  }

  public func loadAvatarImage(
    jid: BareJid,
    imageId: ImageId
  ) -> AnyPublisher<XmppAvatarData?, Error> {
    Deferred {
      Future { promise in
        let requestId = UUID().uuidString

        self.loadAvatarImageCompletionHandlers[requestId] = { result in
          promise(result)
        }

        do {
          try self.client.loadAvatarImage(requestId: requestId, from: jid, imageId: imageId)
        } catch {
          self.loadAvatarImageCompletionHandlers[requestId] = nil
          promise(.failure(error))
        }
      }
    }
    .subscribe(on: self.delegateQueue)
    .eraseToAnyPublisher()
  }
}

extension ProseClient: XmppAccountObserver {
  public func didConnect() {
    self.callDelegateOnQueue { delegate in
      delegate.proseClientDidConnect(self)
    }
  }

  public func didDisconnect() {
    self.isConnected = false

    // We need to receive an error here from the core lib. Unfortunately the core lib itself
    // doesn't receive an error for invalid credentials from libstrophe at this point.
    self.callDelegateOnQueue { delegate in
      delegate.proseClient(self, connectionDidFailWith: nil)
    }
  }

  public func didReceiveMessage(message: XmppMessage) {
    self.callDelegateOnQueue { delegate in
      delegate.proseClient(self, didReceiveMessage: message)
    }
  }

  public func didReceiveMessageCarbon(message: XmppForwardedMessage) {
    self.callDelegateOnQueue { delegate in
      delegate.proseClient(self, didReceiveMessageCarbon: message)
    }
  }

  public func didReceiveSentMessageCarbon(message: XmppForwardedMessage) {
    self.callDelegateOnQueue { delegate in
      delegate.proseClient(self, didReceiveSentMessageCarbon: message)
    }
  }

  public func didReceiveRoster(roster: XmppRoster) {
    self.callDelegateOnQueue { delegate in
      delegate.proseClient(self, didReceiveRoster: roster)
    }
  }

  public func didReceivePresence(presence: XmppPresence) {
    self.callDelegateOnQueue { delegate in
      delegate.proseClient(self, didReceivePresence: presence)
    }
  }

  public func didReceivePresenceSubscriptionRequest(from: BareJid) {
    self.callDelegateOnQueue { delegate in
      delegate.proseClient(self, didReceivePresenceSubscriptionRequest: from)
    }
  }

  public func didReceiveArchivingPreferences(preferences: XmppmamPreferences) {
    self.callDelegateOnQueue { delegate in
      delegate.proseClient(self, didReceiveArchivingPreferences: preferences)
    }
  }

  public func didReceiveMessagesInChat(
    requestId: String,
    jid _: BareJid,
    messages: [XmppForwardedMessage],
    isComplete: Bool
  ) {
    self.delegateQueue.async { [weak self] in
      guard let self = self else {
        return
      }
      let completionHandler = self.loadMessagesCompletionHandlers[requestId]
      self.loadMessagesCompletionHandlers.removeValue(forKey: requestId)
      completionHandler?(.success(messages), isComplete)
    }
  }

  public func didLoadAvatarImage(requestId: String, jid _: BareJid, image: XmppAvatarData?) {
    let completionHandler = self.loadAvatarImageCompletionHandlers.removeValue(forKey: requestId)
    completionHandler?(.success(image))
  }

  public func didLoadAvatarMetadata(
    requestId: String,
    jid _: BareJid,
    metadata: [XmppAvatarMetadataInfo]
  ) {
    self.delegateQueue.async { [weak self] in
      guard let self = self else {
        return
      }
      let completionHandler = self.loadAvatarMetadataCompletionHandlers
        .removeValue(forKey: requestId)
      completionHandler?(.success(metadata.last))
    }
  }

  public func didSetAvatarImage(requestId: String, imageId: ImageId) {
    self.delegateQueue.async { [weak self] in
      guard let self = self else {
        return
      }
      let completionHandler = self.setAvatarImageCompletionHandlers.removeValue(forKey: requestId)
      completionHandler?(.success(imageId))
    }
  }

  public func didReceiveUpdatedAvatarMetadata(
    jid _: BareJid,
    metadata _: [XmppAvatarMetadataInfo]
  ) {}
}

private extension ProseClient {
  func callDelegateOnQueue(_ handler: @escaping (ProseClientDelegate) -> Void) {
    weak var delegate = self.delegate
    self.delegateQueue.async {
      if let delegate = delegate {
        handler(delegate)
      }
    }
  }
}
