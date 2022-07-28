//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppKit
import ComposableArchitecture
import ProseCoreTCA
import WebKit

struct ToggleReactionHandler: WebMessageHandler {
  struct Body: Decodable {
    let ids: [Message.ID]
    let reaction: String
  }

  static let jsHandlerName: String = "toggleReaction"
  static let jsEventName: String = "message:reactions:react"
  static let jsFunctionName: String = "toggleReaction"

  weak var viewStore: ViewStore<ChatView.State, ChatView.Action>?

  func handle(_: WKScriptMessage, body: Body) {
    logger.trace("Toggling reaction \(body.reaction) on \(String(describing: body.ids))…")

    guard let reaction = body.reaction.first else { return }

    assert(self.viewStore != nil)
    self.viewStore?.send(.toggleReaction(reaction, for: body.ids))
  }
}
