//
//  UnreadSection.swift
//  Prose
//
//  Created by Rémi Bardon on 27/03/2022.
//

import ConversationFeature
import ProseCoreStub
import ProseUI
import SharedModels
import SwiftUI

public struct UnreadSectionModel: Equatable {
    let chatId: ChatID
    let chatTitle: String
    var messages: [MessageViewModel]

    public init(
        chatId: ChatID,
        chatTitle: String,
        messages: [MessageViewModel]
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
                        Button {
                            print("Reply tapped")
                        } label: {
                            // FIXME: Localize
                            Label("Reply", systemImage: "arrowshape.turn.up.right")
                                .frame(maxWidth: .infinity)
                        }
                        .foregroundColor(.accentColor)
                        .unredacted()
                        Button {
                            print("Mark read tapped")
                        } label: {
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

// struct UnreadSection_Previews: PreviewProvider {
//    static var previews: some View {
//        UnreadSection()
//    }
// }
