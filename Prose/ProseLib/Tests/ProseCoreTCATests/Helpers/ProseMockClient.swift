//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import ProseCore
import ProseCoreClientFFI

final class ProseMockClient: ProseClientProtocol {
  let jid: BareJid
  let delegate: ProseClientDelegate

  var impl = ProseMockClientImpl()

  init(jid: BareJid, delegate: ProseCore.ProseClientDelegate) {
    self.jid = jid
    self.delegate = delegate
  }

  func connect(credential: ProseCore.Credential) throws {
    try self.impl.connect(credential)
  }

  func disconnect() {
    self.impl.disconnect()
  }

  func sendMessage(id: String, to: BareJid, text: String, chatState: XmppChatState?) throws {
    try self.impl.sendMessage(id, to, text, chatState)
  }

  func updateMessage(id: String, newID: String, to: BareJid, text: String) throws {
    try self.impl.updateMessage(id, newID, to, text)
  }

  func sendChatState(to: BareJid, chatState: XmppChatState) throws {
    try self.impl.sendChatState(to, chatState)
  }

  func sendPresence(show: XmppShowKind, status: String?) throws {
    try self.impl.sendPresence(show, status)
  }

  func loadRoster() throws {
    try self.impl.loadRoster()
  }

  func retractMessage(to: BareJid, messageId: MessageId) throws {
    try self.impl.retractMessage(to, messageId)
  }

  func loadMessagesInChat(
    jid: BareJid,
    before: MessageId?,
    completion: @escaping LoadMessagesCompletionHandler
  ) {
    self.impl.loadMessagesInChat(jid, before, completion)
  }

  func sendReactions(_ reactions: Set<String>, to: BareJid, messageId: MessageId) throws {
    try self.impl.sendReactions(reactions, to, messageId)
  }

  func addUserToRoster(jid: BareJid, nickname: String?, groups: Set<String>) throws {
    try self.impl.addUserToRoster(jid, nickname, groups)
  }

  func removeUserAndUnsubscribeFromPresence(jid: BareJid) throws {
    try self.impl.removeUserAndUnsubscribeFromPresence(jid)
  }

  func subscribeToUserPresence(jid: BareJid) throws {
    try self.impl.subscribeToUserPresence(jid)
  }

  func unsubscribeFromUserPresence(jid: BareJid) throws {
    try self.impl.unsubscribeFromUserPresence(jid)
  }

  func grantPresencePermissionToUser(jid: BareJid) throws {
    try self.impl.grantPresencePermissionToUser(jid)
  }

  func revokeOrRejectPresencePermissionFromUser(jid: BareJid) throws {
    try self.impl.revokeOrRejectPresencePermissionFromUser(jid)
  }
}

extension ProseMockClient {
  static func provider(
    _ handler: @escaping (ProseMockClient) -> Void
  ) -> ProseClientProvider<ProseMockClient> {
    { jid, delegate, _ in
      let client = ProseMockClient(jid: jid, delegate: delegate)
      handler(client)
      return client
    }
  }
}

struct ProseMockClientImpl {
  var connect: (ProseCore.Credential) throws -> Void = { _ in }
  var disconnect: () -> Void = {}
  var sendMessage: (String, BareJid, String, XmppChatState?) throws -> Void = { _, _, _, _ in }
  var updateMessage: (String, String, BareJid, String) throws -> Void = { _, _, _, _ in }
  var sendChatState: (BareJid, XmppChatState) throws -> Void = { _, _ in }
  var sendPresence: (XmppShowKind, String?) throws -> Void = { _, _ in }
  var loadRoster: () throws -> Void = {}
  var retractMessage: (BareJid, MessageId) throws -> Void = { _, _ in }
  var loadMessagesInChat: (BareJid, MessageId?, LoadMessagesCompletionHandler)
    -> Void = { _, _, _ in
    }

  var sendReactions: (Set<String>, BareJid, MessageId) throws -> Void = { _, _, _ in }
  var addUserToRoster: (BareJid, String?, Set<String>) throws -> Void = { _, _, _ in }
  var removeUserAndUnsubscribeFromPresence: (BareJid) throws -> Void = { _ in }
  var subscribeToUserPresence: (BareJid) throws -> Void = { _ in }
  var unsubscribeFromUserPresence: (BareJid) throws -> Void = { _ in }
  var grantPresencePermissionToUser: (BareJid) throws -> Void = { _ in }
  var revokeOrRejectPresencePermissionFromUser: (BareJid) throws -> Void = { _ in }
}
