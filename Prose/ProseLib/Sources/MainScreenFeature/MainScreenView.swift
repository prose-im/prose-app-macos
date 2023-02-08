import AddressBookFeature
import ComposableArchitecture
import ConversationFeature
import PasteboardClient
import ProseCoreTCA
import SidebarFeature
import SwiftUI
import TcaHelpers
import Toolbox
import UnreadFeature

public struct MainScreenView: View {
  private let store: StoreOf<MainScreen>
  @ObservedObject private var viewStore: ViewStore<SessionState<None>, Never>

  // swiftlint:disable:next type_contents_order
  public init(store: StoreOf<MainScreen>) {
    self.store = store
    self.viewStore = ViewStore(
      store.scope(state: { SessionState(currentUser: $0.currentUser, childState: .none) })
        .actionless
    )
  }

  public var body: some View {
    NavigationView {
      SidebarView(store: self.store
        .scope(state: \.scoped.sidebar, action: MainScreen.Action.sidebar))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("Sidebar")

      SwitchStore(self.store.scope(state: \.route)) {
        CaseLet(
          state: /MainScreen.Route.unreadStack,
          action: MainScreen.Action.unreadStack,
          then: UnreadScreen.init(store:)
        )
        CaseLet(
          state: { route in
            CasePath(MainScreen.Route.chat).extract(from: route)
              .map { SessionState(currentUser: self.viewStore.currentUser, childState: $0) }
          },
          action: MainScreen.Action.chat,
          then: ConversationScreen.init(store:)
        )
        Default {
          Text("Not implemented.")
        }
      }
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier("MainContent")
    }
  }
}
