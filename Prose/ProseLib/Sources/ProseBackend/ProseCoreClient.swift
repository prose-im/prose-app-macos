//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppDomain
import Combine
import Foundation

public struct ProseCoreClient {
  public var connectionStatus: () -> AsyncStream<ConnectionStatus>

  public var events: () -> AsyncStream<ClientEvent>

  public var connect: (Credentials, _ retry: Bool) async throws -> Void
  public var disconnect: () async throws -> Void

  public var loadProfile: (BareJid) async throws -> UserProfile
  public var loadContacts: () async throws -> [Contact]
  public var loadAvatar: (BareJid) async throws -> URL?

  public var sendMessage: (_ to: BareJid, _ body: String) async throws -> Void
  public var updateMessage: (
    _ conversation: BareJid,
    _ id: MessageId,
    _ body: String
  ) async throws -> Void
  public var toggleReactionToMessage: (
    _ conversation: BareJid,
    _ id: MessageId,
    _ emoji: Emoji
  ) async throws -> Void
  public var retractMessage: (_ conversation: BareJid, _ id: MessageId) async throws -> Void

  public var sendChatState: (_ conversation: BareJid, _ state: ChatState) async throws -> Void

  public var loadLatestMessages: (
    _ conversation: BareJid,
    _ since: StanzaId?,
    _ loadFromServer: Bool
  ) async throws -> [Message]

  public var loadMessagesBefore: (
    _ conversation: BareJid,
    _ before: StanzaId
  ) async throws -> MessagesPage

  public var loadMessagesWithIds: (
    _ conversation: BareJid,
    _ ids: [MessageId]
  ) async throws -> [Message]
}
