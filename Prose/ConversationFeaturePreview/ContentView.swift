//
//  ContentView.swift
//  ConversationFeaturePreview
//
//  Created by Rémi Bardon on 22/06/2022.
//  Copyright © 2022 Prose. All rights reserved.
//

import Combine
import ComposableArchitecture
import ConversationFeature
import ProseCoreTCA
import SwiftUI

struct ContentView: View {
    let store: Store<ConversationState, ConversationAction>

    init() {
        var client = ProseClient.noop

        let chatSubject = CurrentValueSubject<[Message], Never>([])

        client.sendMessage = { jid, body in
            .fireAndForget {
                chatSubject.value.append(
                    .init(from: jid, id: .selfAssigned(UUID()), kind: nil, body: body, timestamp: Date())
                )
            }
        }
        client.messagesInChat = { _ in
            chatSubject.eraseToEffect()
        }

        self.store = Store(
            initialState: ConversationState(
                chatId: "valerian@prose.org"
            ),
            reducer: conversationReducer,
            environment: ConversationEnvironment(
                proseClient: client,
                mainQueue: .main
            )
        )
    }

    var body: some View {
        ConversationScreen(store: self.store)
            .frame(minWidth: 960, minHeight: 320)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
