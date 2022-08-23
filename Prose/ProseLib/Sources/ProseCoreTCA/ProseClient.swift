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
  public var login: (_ jid: JID, _ password: String) -> Effect<None, EquatableError>
  public var logout: (_ jid: JID) -> Effect<None, Never>

  public var roster: () -> Effect<Roster, EquatableError>
  public var activeChats: () -> Effect<[JID: Chat], EquatableError>
  public var presence: () -> Effect<[JID: Presence], EquatableError>
  public var userInfos: (Set<JID>) -> Effect<[JID: UserInfo], EquatableError>

  /// Returns an Effect that publishes new messages as they arrive.
  ///
  /// The messages published by this Effect do not include any message carbons.
  public var incomingMessages: () -> Effect<Message, Never>

  /// This will probably be split up in two methods/publishers. One where we can load older
  /// messages and a second one where the new messages come in.
  public var messagesInChat: (_ with: JID) -> Effect<IdentifiedArrayOf<Message>, EquatableError>

  /// Sends a message with the contents of `body` to the user with the specified JID.
  public var sendMessage: (_ to: JID, _ body: String) -> Effect<None, EquatableError>

  /// Updates the message identified by `id` with the contents of `body` in a conversation
  /// identified by `to`.
  public var updateMessage: (
    _ to: JID,
    _ id: Message.ID,
    _ body: String
  ) -> Effect<None, EquatableError>
  public var addReaction: (
    _ to: JID,
    _ id: Message.ID,
    _ reaction: Reaction
  ) -> Effect<None, EquatableError>

  public var toggleReaction: (
    _ to: JID,
    _ id: Message.ID,
    _ reaction: Reaction
  ) -> Effect<None, EquatableError>

  /// Retracts the message identified by `id` sent to a conversation identified by `to`.
  public var retractMessage: (_ to: JID, _ id: Message.ID) -> Effect<None, EquatableError>

  /// Sends the user's current state `state` in a conversation identified by `to`.
  public var sendChatState: (_ to: JID, _ state: ChatState.Kind) -> Effect<None, EquatableError>

  /// Sets the user's presence to `kind` with an optional status message `status`.
  public var sendPresence: (
    _ kind: Presence.Show,
    _ status: String?
  ) -> Effect<None, EquatableError>

  /// Marks all messages read in a conversation identified by `jid` to
  /// update `Chat.numberOfUnreadMessages` returned from the `activeChats` publisher.
  public var markMessagesReadInChat: (_ jid: JID) -> Effect<None, EquatableError>

  public var fetchPastMessagesInChat: (_ jid: JID) -> Effect<None, EquatableError>

  /// Sets the given image as the current user's avatar image.
  public var setAvatarImage: (CGImage) -> Effect<None, EquatableError>
}
