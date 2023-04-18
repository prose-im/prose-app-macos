//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import Assets
import ComposableArchitecture
import ConversationFeature
import ProseUI
import SwiftUI

public struct UnreadScreen: View {
  private let store: StoreOf<UnreadScreenReducer>
  private var actions: ViewStore<Void, UnreadScreenReducer.Action>

  public init(store: StoreOf<UnreadScreenReducer>) {
    self.store = store
    self.actions = ViewStore(store.stateless)
  }

  public var body: some View {
    self.content()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Colors.Background.message.color)
      .toolbar(content: Toolbar.init)
      .onAppear { self.actions.send(.onAppear) }
      .groupBoxStyle(.spotlight)
  }

  private func content() -> some View {
    WithViewStore(self.store.scope(state: \.messages.isEmpty)) { noMessage in
      if noMessage.state {
        self.nothing()
      } else {
        self.list()
      }
    }
  }

  private func nothing() -> some View {
    Text("Looks like you read everything 🎉")
      .font(.largeTitle.bold())
      .foregroundColor(.secondary)
      .padding()
      .unredacted()
  }

  private func list() -> some View {
    ScrollView {
      VStack(spacing: 24) {
        WithViewStore(self.store.scope(state: \.messages)) { messages in
          ForEach(messages.state, id: \.chatId, content: UnreadSection.init(model:))
        }
      }
      .padding(24)
    }
  }
}
