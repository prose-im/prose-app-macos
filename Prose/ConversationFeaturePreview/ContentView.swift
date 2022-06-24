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
                chatId: "valerian@prose.org"
            ),
            reducer: conversationReducer,
            environment: ConversationEnvironment(
                proseClient: .live(),
                mainQueue: .main
            )
        ))
        .frame(minWidth: 960, minHeight: 320)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
