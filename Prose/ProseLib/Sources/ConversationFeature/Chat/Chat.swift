//
//  Chat.swift
//  Prose
//
//  Created by Rémi Bardon on 03/03/2022.
//  Copyright © 2022 Prose. All rights reserved.
//

import Assets
import ComposableArchitecture
import ProseCoreTCA
import SharedModels
import SwiftUI

// MARK: - View

struct Chat: View {
    typealias State = ChatState
    typealias Action = Never

    let store: Store<State, Action>

    var body: some View {
        WithViewStore(self.store.scope(state: \State.messages)) { messages in
            let messages = messages.state
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(messages) { message in
                            MessageView(model: message)
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity)
                .onAppear {
                    if let id = messages.last?.id {
                        scrollView.scrollTo(id, anchor: .top)
                    }
                }
            }
            .background(Colors.Background.message.color)
        }
    }
}

struct ChatState: Equatable {
    var messages = [Message]()
}
