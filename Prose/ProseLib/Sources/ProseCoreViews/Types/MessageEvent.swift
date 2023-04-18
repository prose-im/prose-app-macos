//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppDomain

public enum MessageEvent: Equatable {
  case showMenu(MessageMenuHandlerPayload)
  case toggleReaction(ToggleReactionHandlerPayload)
  case showReactions(ShowReactionsHandlerPayload)
  case reachedEndOfList(ReachedEndOfListPayload)
}

public struct MessageMenuHandlerPayload: Equatable, Decodable {
  public let id: Message.ID?
  public let origin: EventOrigin
}

public struct ShowReactionsHandlerPayload: Equatable, Decodable {
  public let id: Message.ID?
  public let origin: EventOrigin
}

public struct ToggleReactionHandlerPayload: Equatable, Decodable {
  public let id: Message.ID?
  public let reaction: Emoji
}

public struct ReachedEndOfListPayload: Equatable, Decodable {
  public enum Direction: String, Decodable {
    case forwards
    case backwards
  }
  public let direction: Direction
}

public extension MessageEvent {
  enum Kind: String {
    case showMenu = "message:actions:view"
    case toggleReaction = "message:reactions:react"
    case showReactions = "message:reactions:view"
    case reachedEndOfList = "message:history:seek"
  }
}
