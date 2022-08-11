//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import struct ProseCoreTCA.Message

public enum MessageEvent: Equatable {
  case showMenu(MessageMenuHandlerPayload)
  case toggleReaction(ToggleReactionHandlerPayload)
  case showReactions(ShowReactionsHandlerPayload)
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
  public let reaction: String
}

public extension MessageEvent {
  enum Kind: String {
    case showMenu = "message:actions:view"
    case toggleReaction = "message:reactions:react"
    case showReactions = "message:reactions:view"
  }
}
