//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import Foundation
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

  /// Returns an Effect that publishes new messages as they arrive.
  public var incomingMessages: () -> Effect<Message, Never>

  /// This will probably be split up in two methods/publishers. One where we can load older
  /// messages and a second one where the new messages come in.
  public var messagesInChat: (_ with: JID) -> Effect<[Message], EquatableError>

  public var sendMessage: (_ to: JID, _ body: String) -> Effect<None, EquatableError>
  public var updateMessage: (
    _ to: JID,
    _ id: Message.ID,
    _ body: String
  ) -> Effect<None, EquatableError>

  public var sendChatState: (_ to: JID, _ state: ChatState.Kind) -> Effect<None, EquatableError>
  public var sendPresence: (
    _ kind: Presence.Show,
    _ status: String?
  ) -> Effect<None, EquatableError>

  public var markMessagesReadInChat: (_ jid: JID) -> Effect<None, EquatableError>
}
