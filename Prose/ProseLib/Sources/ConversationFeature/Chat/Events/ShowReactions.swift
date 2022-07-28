//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppKit
import ComposableArchitecture
import ProseCoreTCA
import WebKit

struct ShowReactionsHandler: WebMessageHandler {
  struct Body: Decodable {
    let ids: [Message.ID]
  }

  static let jsHandlerName: String = "showReactions"
  static let jsEventName: String = "message:reactions:view"
  static let jsFunctionName: String = "showReactions"

  weak var viewStore: ViewStore<ChatView.State, ChatView.Action>?

  func handle(_: WKScriptMessage, body: Body) {
    logger.trace("Showing reactions for \(String(describing: body.ids))…")

    if let messageId: Message.ID = body.ids.first {
      assert(self.viewStore != nil)
      self.viewStore?.send(.messageMenuItemTapped(.addReaction(messageId)))
    } else {
      logger.notice("Cannot show reactions: No message selected")
    }
  }
}
