//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import ProseCoreClientFFI

public typealias ProseClientProvider<Client: ProseClientProtocol> =
  (FullJid, ProseClientDelegate, DispatchQueue) -> Client

public typealias LoadMessagesCompletionHandler =
  (Result<[XmppForwardedMessage], Error>, _ isComplete: Bool) -> Void

public protocol ProseClientProtocol: AnyObject {
  var jid: FullJid { get }

  func connect(credential: Credential) throws
  func disconnect()

  func sendMessage(
    id: String,
    to: BareJid,
    text: String,
    chatState: XmppChatState?
  ) throws

  func updateMessage(
    id: String,
    newId: String,
    to: BareJid,
    text: String
  ) throws

  func retractMessage(to: BareJid, messageId: MessageId) throws

  func loadMessagesInChat(
    jid: BareJid,
    before: MessageId?,
    completion: @escaping LoadMessagesCompletionHandler
  )

  func sendChatState(to: BareJid, chatState: XmppChatState) throws
  func sendPresence(show: XmppShowKind, status: String?) throws
  func sendReactions(_ reactions: Set<String>, to: BareJid, messageId: MessageId) throws

  func loadRoster() throws

  func addUserToRoster(jid: BareJid, nickname: String?, groups: Set<String>) throws
  func removeUserAndUnsubscribeFromPresence(jid: BareJid) throws
  func subscribeToUserPresence(jid: BareJid) throws
  func unsubscribeFromUserPresence(jid: BareJid) throws
  func grantPresencePermissionToUser(jid: BareJid) throws
  func revokeOrRejectPresencePermissionFromUser(jid: BareJid) throws
}

public protocol ProseClientDelegate: AnyObject {
  func proseClientDidConnect(_ client: ProseClientProtocol)
  func proseClient(
    _ client: ProseClientProtocol,
    connectionDidFailWith error: Error?
  )
  func proseClient(
    _ client: ProseClientProtocol,
    didReceiveRoster roster: XmppRoster
  )
  func proseClient(
    _ client: ProseClientProtocol,
    didReceiveMessage message: XmppMessage
  )
  func proseClient(
    _ client: ProseClientProtocol,
    didReceiveMessageCarbon message: XmppForwardedMessage
  )
  func proseClient(
    _ client: ProseClientProtocol,
    didReceiveSentMessageCarbon message: XmppForwardedMessage
  )
  func proseClient(
    _ client: ProseClientProtocol,
    didReceivePresence presence: XmppPresence
  )
  func proseClient(
    _ client: ProseClientProtocol,
    didReceivePresenceSubscriptionRequest from: BareJid
  )
  func proseClient(
    _ client: ProseClientProtocol,
    didReceiveArchivingPreferences preferences: XmppmamPreferences
  )
}
