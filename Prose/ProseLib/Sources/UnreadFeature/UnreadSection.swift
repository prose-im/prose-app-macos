//
//  UnreadSection.swift
//  Prose
//
//  Created by Rémi Bardon on 27/03/2022.
//

import ConversationFeature
import ProseUI
import SharedModels
import SwiftUI

struct UnreadSectionModel {
    let chatId: ChatID
    let messages: [MessageViewModel]
}

struct UnreadSection: View {
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
                        Button {
                            print("Mark read tapped")
                        } label: {
                            // FIXME: Localize
                            Text("Mark read")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(width: 96)
                    .labelStyle(.vertical)
                    .buttonStyle(.shadowed)
                }
            }
        } label: {
            HStack {
                Label(label(for: model.chatId), systemImage: model.chatId.icon.rawValue)
                    .labelStyle(.coloredIcon)
                    .font(.title3.bold())
                Spacer()
                Text(model.messages.last!.timestamp, format: .relative(presentation: .named))
                    .foregroundColor(.secondary)
            }
        }
    }

    private func label(for chatId: ChatID) -> String {
        switch chatId {
        case let .person(id: userId):
            return UserStore.shared.user(for: userId)?.fullName ?? "Unknown"
        case let .group(id: groupId):
            return groupId
        }
    }
}

// struct UnreadSection_Previews: PreviewProvider {
//    static var previews: some View {
//        UnreadSection()
//    }
// }
