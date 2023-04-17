//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
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
  private let store: StoreOf<MainScreen>
  @ObservedObject private var viewStore: ViewStore<SessionState<None>, Never>

  // swiftlint:disable:next type_contents_order
  public init(store: StoreOf<MainScreen>) {
    self.store = store
    self.viewStore = ViewStore(
      store.scope(state: { $0.get { _ in .none } }).actionless
    )
  }

  public var body: some View {
    NavigationView {
      SidebarView(
        store: self.store
          .scope(state: \.scoped.sidebar, action: MainScreen.Action.sidebar)
      )
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier("Sidebar")

      ZStack(alignment: .top) {
        IfLetStore(self.store.scope(
          state: \.sessionRoute.unreadStack,
          action: MainScreen.Action.unreadStack
        )) { store in
          UnreadScreen(store: store)
        }
        IfLetStore(self.store.scope(
          state: \.sessionRoute.chat,
          action: MainScreen.Action.chat
        )) { store in
          ConversationScreen(store: store)
        }
        if self.viewStore.selectedAccount.status != .connected {
          OfflineBanner(account: self.viewStore.selectedAccount)
        }
      }
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier("MainContent")
    }
  }
}

#warning("Localize me")
struct OfflineBanner: View {
  var account: Account

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
        if self.account.status == .connecting {
          ProgressView().controlSize(.mini)
        }
      }.disabled(self.account.status == .connecting)
    }
    .frame(maxWidth: .infinity)
    .padding()
    .background(Colors.State.coolGrey.color)
  }
}

#if DEBUG
  struct OfflineBanner_Previews: PreviewProvider {
    static var previews: some View {
      OfflineBanner(account: .init(jid: "hello@prose.org", status: .connected))
    }
  }
#endif
