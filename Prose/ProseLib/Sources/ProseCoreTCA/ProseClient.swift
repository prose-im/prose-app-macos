//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import CoreGraphics
import Foundation
import IdentifiedCollections
import Toolbox

public struct Account: Hashable {
  public enum Status: Hashable {
    case connecting
    case connected
    case error(EquatableError)
  }

  public var jid: JID
  public var status: Status
}

public struct ProseClient {
  public var login: (_ jid: JID, _ password: String) -> EffectPublisher<None, EquatableError>
  public var logout: (_ jid: JID) -> EffectTask<None>

  public var roster: () -> EffectPublisher<Roster, EquatableError>
  public var activeChats: () -> EffectPublisher<[JID: Chat], EquatableError>
  public var presence: () -> EffectPublisher<[JID: Presence], EquatableError>
  public var userInfos: (Set<JID>) -> EffectPublisher<[JID: UserInfo], EquatableError>

  /// Returns an Effect that publishes new messages as they arrive.
  ///
  /// The messages published by this Effect do not include any message carbons.
  public var incomingMessages: () -> EffectTask<Message>

  /// This will probably be split up in two methods/publishers. One where we can load older
  /// messages and a second one where the new messages come in.
  public var messagesInChat: (_ with: JID)
    -> EffectPublisher<IdentifiedArrayOf<Message>, EquatableError>

  /// Sends a message with the contents of `body` to the user with the specified JID.
  public var sendMessage: (_ to: JID, _ body: String) -> EffectPublisher<None, EquatableError>

  /// Updates the message identified by `id` with the contents of `body` in a conversation
  /// identified by `to`.
  public var updateMessage: (
    _ to: JID,
    _ id: Message.ID,
    _ body: String
  ) -> EffectPublisher<None, EquatableError>
  public var addReaction: (
    _ to: JID,
    _ id: Message.ID,
    _ reaction: Reaction
  ) -> EffectPublisher<None, EquatableError>

  public var toggleReaction: (
    _ to: JID,
    _ id: Message.ID,
    _ reaction: Reaction
  ) -> EffectPublisher<None, EquatableError>

  /// Retracts the message identified by `id` sent to a conversation identified by `to`.
  public var retractMessage: (_ to: JID, _ id: Message.ID) -> EffectPublisher<None, EquatableError>

  /// Sends the user's current state `state` in a conversation identified by `to`.
  public var sendChatState: (_ to: JID, _ state: ChatState.Kind)
    -> EffectPublisher<None, EquatableError>

  /// Sets the user's presence to `kind` with an optional status message `status`.
  public var sendPresence: (
    _ kind: Presence.Show,
    _ status: String?
  ) -> EffectPublisher<None, EquatableError>

  /// Marks all messages read in a conversation identified by `jid` to
  /// update `Chat.numberOfUnreadMessages` returned from the `activeChats` publisher.
  public var markMessagesReadInChat: (_ jid: JID) -> EffectPublisher<None, EquatableError>

  public var fetchPastMessagesInChat: (_ jid: JID) -> EffectPublisher<None, EquatableError>

  /// Sets the given image as the current user's avatar image.
  public var setAvatarImage: (CGImage) -> EffectPublisher<None, EquatableError>
}
