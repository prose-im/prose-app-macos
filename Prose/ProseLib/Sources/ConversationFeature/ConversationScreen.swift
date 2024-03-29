//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import ComposableArchitecture
import IdentifiedCollections
import PasteboardClient
import SwiftUI
import Toolbox

public struct ConversationScreen: View {
  private let store: StoreOf<ConversationScreenReducer>
  private var actions: ViewStore<Void, ConversationScreenReducer.Action>

  public init(store: StoreOf<ConversationScreenReducer>) {
    self.store = store
    self.actions = ViewStore(self.store.stateless)
  }

  public var body: some View {
    Chat(store: self.store.scope(state: \.chat, action: ConversationScreenReducer.Action.chat))
      .safeAreaInset(edge: .bottom, spacing: 0) {
        MessageBar(
          store: self.store
            .scope(state: \.messageBar, action: ConversationScreenReducer.Action.messageBar)
        )
        // Make footer have a higher priority, to be accessible over the scroll view
        .accessibilitySortPriority(1)
      }
      .accessibilityIdentifier("ChatWebView")
      .accessibilityElement(children: .contain)
      .onAppear { self.actions.send(.onAppear) }
      .onDisappear { self.actions.send(.onDisappear) }
      .safeAreaInset(edge: .trailing, spacing: 0) {
        WithViewStore(self.store.scope(state: \.toolbar.childState.isShowingInfo)) { showingInfo in
          HStack(spacing: 0) {
            ConversationInfoView(
              store: self.store.scope(state: \.info, action: ConversationScreenReducer.Action.info)
            ).frame(width: 256)
          }
          .frame(width: showingInfo.state ? 256 : 0, alignment: .leading)
          .clipped()
        }
      }
      .toolbar {
        Toolbar(
          store: self.store
            .scope(state: \.toolbar, action: ConversationScreenReducer.Action.toolbar)
        )
      }
      // Hide the navigation title so that our contact's name and availability indicator can act
      // as the title instead.
      .navigationTitle("")
  }
}
