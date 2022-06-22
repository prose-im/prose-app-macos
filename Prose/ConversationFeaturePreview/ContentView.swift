//
//  ContentView.swift
//  ConversationFeaturePreview
//
//  Created by Rémi Bardon on 22/06/2022.
//  Copyright © 2022 Prose. All rights reserved.
//

import ComposableArchitecture
import ConversationFeature
import SwiftUI

struct ContentView: View {
    var body: some View {
        ConversationScreen(store: Store(
            initialState: ConversationState(
                chatId: .person(id: "valerian@prose.org"),
                recipient: "Valerian"
            ),
            reducer: conversationReducer,
            environment: ConversationEnvironment(
                userStore: .stub,
                messageStore: .stub,
                statusStore: .stub,
                securityStore: .stub
            )
        ))
        .frame(minWidth: 720, minHeight: 320)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
