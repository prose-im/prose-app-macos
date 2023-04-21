//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AddressBookFeature
import AppDomain
import Assets
import ComposableArchitecture
import ConversationFeature
import PasteboardClient
import SidebarFeature
import SwiftUI
import Toolbox
import UnreadFeature

public struct MainScreenView: View {
  private let store: StoreOf<MainScreenReducer>

  // swiftlint:disable:next type_contents_order
  public init(store: StoreOf<MainScreenReducer>) {
    self.store = store
  }

  public var body: some View {
    NavigationView {
      SidebarView(
        store: self.store
          .scope(state: \.sidebar, action: MainScreenReducer.Action.sidebar)
      )
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier("Sidebar")

      ZStack(alignment: .top) {
        IfLetStore(self.store.scope(
          state: \.sessionRoute.unreadStack,
          action: MainScreenReducer.Action.unreadStack
        )) { store in
          UnreadScreen(store: store)
        }
        IfLetStore(self.store.scope(
          state: \.sessionRoute.chat,
          action: MainScreenReducer.Action.chat
        )) { store in
          ConversationScreen(store: store)
        }
        WithViewStore(self.store.scope(state: \.selectedAccount)) { viewStore in
          if viewStore.state.status != .connected {
            OfflineBanner(status: viewStore.state.status)
          }
        }
      }
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier("MainContent")
    }
  }
}

#warning("Localize me")
struct OfflineBanner: View {
  var status: ConnectionStatus

  var body: some View {
    HStack {
      Image(systemName: "hazardsign.fill")
      Text("You are offline")
      Text("New messages will not appear, drafts will be saved for later.")
        .opacity(0.55)
        .font(.callout)
      Spacer()
      Button(action: {}) {
        Text("Reconnect")
        if self.status == .connecting {
          ProgressView().controlSize(.mini)
        }
      }.disabled(self.status == .connecting)
    }
    .frame(maxWidth: .infinity)
    .padding()
    .background(Colors.State.coolGrey.color)
  }
}

#if DEBUG
  struct OfflineBanner_Previews: PreviewProvider {
    static var previews: some View {
      OfflineBanner(status: .connected)
    }
  }
#endif
