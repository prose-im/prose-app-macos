//
//  UnreadSection.swift
//  Prose
//
//  Created by Rémi Bardon on 27/03/2022.
//

import ConversationFeature
import ProseCoreTCA
import ProseUI
import SwiftUI

public struct UnreadSectionModel: Equatable {
    let chatId: ChatID
    let chatTitle: String
    var messages: [Message]

    public init(
        chatId: ChatID,
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
                    ForEach(model.messages, content: MessageView.init(model:))
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
                Label(model.chatTitle, systemImage: model.chatId.icon.rawValue)
                    .labelStyle(.coloredIcon)
                    .font(.title3.bold())
                Spacer()
                Text(model.messages.last!.timestamp, format: .relative(presentation: .named))
                    .foregroundColor(.secondary)
            }
        }
        .disabled(redactionReasons.contains(.placeholder))
    }
}

private extension ChatID {
    var icon: Icon {
        switch self {
        case .person:
            return Icon.directMessage
        case .group:
            return Icon.group
        }
    }
}
