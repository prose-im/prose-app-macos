//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import CoreGraphics
import Foundation
import IdentifiedCollections
import ProseCoreFFI
import Toolbox

public struct ProseClient {
  public var login: (_ jid: BareJid, _ password: String) -> EffectPublisher<None, EquatableError>
  public var logout: (_ jid: BareJid) -> EffectTask<None>

  public var roster: () -> EffectPublisher<Roster, EquatableError>
  public var activeChats: () -> EffectPublisher<[BareJid: Chat], EquatableError>
  public var presence: () -> EffectPublisher<[BareJid: Presence], EquatableError>
  public var userInfos: (Set<BareJid>) -> EffectPublisher<[BareJid: UserInfo], EquatableError>

  /// Returns an Effect that publishes new messages as they arrive.
  ///
  /// The messages published by this Effect do not include any message carbons.
  public var incomingMessages: () -> EffectTask<Message>

  /// This will probably be split up in two methods/publishers. One where we can load older
  /// messages and a second one where the new messages come in.
  public var messagesInChat: (_ with: BareJid)
    -> EffectPublisher<IdentifiedArrayOf<Message>, EquatableError>

  /// Sends a message with the contents of `body` to the user with the specified JID.
  public var sendMessage: (_ to: BareJid, _ body: String) -> EffectPublisher<None, EquatableError>

  /// Updates the message identified by `id` with the contents of `body` in a conversation
  /// identified by `to`.
  public var updateMessage: (
    _ to: BareJid,
    _ id: Message.ID,
    _ body: String
  ) -> EffectPublisher<None, EquatableError>
  public var addReaction: (
    _ to: BareJid,
    _ id: Message.ID,
    _ reaction: Reaction
  ) -> EffectPublisher<None, EquatableError>

  public var toggleReaction: (
    _ to: BareJid,
    _ id: Message.ID,
    _ reaction: Reaction
  ) -> EffectPublisher<None, EquatableError>

  /// Retracts the message identified by `id` sent to a conversation identified by `to`.
  public var retractMessage: (_ to: BareJid, _ id: Message.ID)
    -> EffectPublisher<None, EquatableError>

  /// Sends the user's current state `state` in a conversation identified by `to`.
  public var sendChatState: (_ to: BareJid, _ state: ChatState.Kind)
    -> EffectPublisher<None, EquatableError>

  /// Sets the user's presence to `kind` with an optional status message `status`.
  public var sendPresence: (
    _ kind: Presence.Show,
    _ status: String?
  ) -> EffectPublisher<None, EquatableError>

  /// Marks all messages read in a conversation identified by `jid` to
  /// update `Chat.numberOfUnreadMessages` returned from the `activeChats` publisher.
  public var markMessagesReadInChat: (_ jid: BareJid) -> EffectPublisher<None, EquatableError>

  public var fetchPastMessagesInChat: (_ jid: BareJid) -> EffectPublisher<None, EquatableError>

  /// Sets the given image as the current user's avatar image.
  public var setAvatarImage: (CGImage) -> EffectPublisher<None, EquatableError>
}

extension DependencyValues {
  public var legacyProseClient: ProseClient {
    get { self[LegacyProseClientKey.self] }
    set { self[LegacyProseClientKey.self] = newValue }
  }

  private enum LegacyProseClientKey: DependencyKey {
    static let liveValue = ProseClient.noop
    static let testValue = ProseClient.noop
  }
}
