//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import ConversationFeature
import ProseUI
import SwiftUI

public struct UnreadSectionModel: Equatable {
  let chatId: BareJid
  let chatTitle: String
  var messages: [Message]

  public init(
    chatId: BareJid,
    chatTitle: String,
    messages: [Message]
  ) {
    self.chatId = chatId
    self.chatTitle = chatTitle
    self.messages = messages
  }
}

struct UnreadSection: View {
  @Environment(\.redactionReasons) private var redactionReasons

  let model: UnreadSectionModel

  var body: some View {
    GroupBox {
      HStack {
        VStack {
          ForEach(self.model.messages, content: MessageView.init(model:))
        }
        VStack {
          VStack {
            Button { logger.info("Reply tapped") } label: {
              // FIXME: Localize
              Label("Reply", systemImage: "arrowshape.turn.up.right")
                .frame(maxWidth: .infinity)
            }
            .foregroundColor(.accentColor)
            .unredacted()
            Button { logger.info("Mark read tapped") } label: {
              // FIXME: Localize
              Text("Mark read")
                .frame(maxWidth: .infinity)
            }
            .unredacted()
          }
          .frame(width: 96)
          .labelStyle(.vertical)
          .buttonStyle(.shadowed)
        }
      }
    } label: {
      HStack {
        Label(self.model.chatTitle, systemImage: Icon.directMessage.rawValue)
          .labelStyle(.coloredIcon)
          .font(.title3.bold())
        Spacer()
        Text(self.model.messages.last!.timestamp, format: .relative(presentation: .named))
          .foregroundColor(.secondary)
      }
    }
    .disabled(self.redactionReasons.contains(.placeholder))
  }
}

#warning("FIXME")
// private extension ChatID {
//  var icon: Icon {
//    switch self {
//    case .person:
//      return Icon.directMessage
//    case .group:
//      return Icon.group
//    }
//  }
// }
