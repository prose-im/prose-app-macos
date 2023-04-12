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

  public var loadLatestMessages: (
    _ conversation: BareJid,
    _ since: StanzaId?,
    _ loadFromServer: Bool
  ) async throws -> [Message]

  public var loadMessagesBefore: (
    _ conversation: BareJid,
    _ before: StanzaId
  ) async throws -> MessagesPage
}
