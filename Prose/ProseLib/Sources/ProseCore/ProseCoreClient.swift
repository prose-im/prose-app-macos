//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import Combine
import Foundation
import Toolbox

public extension CachePolicy {
  static let `default` = CachePolicy.returnCacheDataElseLoad
}

public struct ProseCoreClient {
  public var connectionStatus: () -> AsyncStream<ConnectionStatus>

  public var events: () -> AsyncStream<ClientEvent>

  public var connect: (Credentials, _ retry: Bool) async throws -> Void
  public var disconnect: () async throws -> Void

  public var loadProfile: (BareJid, CachePolicy) async throws -> UserProfile
  public var loadContacts: (CachePolicy) async throws -> [Contact]
  public var loadAvatar: (BareJid, CachePolicy) async throws -> URL?
  public var saveAvatar: (URL) async throws -> Void
  public var setAvailability: (Availability, _ status: String?) async throws -> Void

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

  public var setUserIsComposing: (_ conversation: BareJid, _ isTyping: Bool) async throws -> Void
  public var loadComposingUsersInConversation: (_ conversation: BareJid) async throws -> [BareJid]

  public var loadLatestMessages: (
    _ conversation: BareJid,
    _ since: MessageId?,
    _ loadFromServer: Bool
  ) async throws -> [Message]

  public var loadMessagesBefore: (
    _ conversation: BareJid,
    _ before: MessageId
  ) async throws -> MessagesPage

  public var loadMessagesWithIds: (
    _ conversation: BareJid,
    _ ids: [MessageId]
  ) async throws -> [Message]

  public var saveDraft: (_ conversation: BareJid, _ text: String) async throws -> Void
  public var loadDraft: (_ conversation: BareJid) async throws -> String?

  public var loadAccountSettings: () async throws -> AccountSettings
  public var saveAccountSettings: (AccountSettings) async throws -> Void
}

public extension ProseCoreClient {
  static let noop = ProseCoreClient(
    connectionStatus: { AsyncStream.empty() },
    events: { AsyncStream.empty() },
    connect: { _, _ in try await Task.never() },
    disconnect: { try await Task.never() },
    loadProfile: { _, _ in try await Task.never() },
    loadContacts: { _ in try await Task.never() },
    loadAvatar: { _, _ in try await Task.never() },
    saveAvatar: { _ in try await Task.never() },
    setAvailability: { _, _ in try await Task.never() },
    sendMessage: { _, _ in try await Task.never() },
    updateMessage: { _, _, _ in try await Task.never() },
    toggleReactionToMessage: { _, _, _ in try await Task.never() },
    retractMessage: { _, _ in try await Task.never() },
    setUserIsComposing: { _, _ in try await Task.never() },
    loadComposingUsersInConversation: { _ in try await Task.never() },
    loadLatestMessages: { _, _, _ in try await Task.never() },
    loadMessagesBefore: { _, _ in try await Task.never() },
    loadMessagesWithIds: { _, _ in try await Task.never() },
    saveDraft: { _, _ in try await Task.never() },
    loadDraft: { _ in try await Task.never() },
    loadAccountSettings: { try await Task.never() },
    saveAccountSettings: { _ in try await Task.never() }
  )
}
