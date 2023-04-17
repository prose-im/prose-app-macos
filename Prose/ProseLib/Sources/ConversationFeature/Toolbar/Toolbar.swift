//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

#warning("FIXME")

// import ComposableArchitecture
// import ProseUI
// import SwiftUI
// import ProseBackend
//
// struct Toolbar: ToolbarContent {
//  @Environment(\.redactionReasons) private var redactionReasons
//
//  let store: StoreOf<ToolbarReducer>
//
//  var body: some ToolbarContent {
//    ToolbarItemGroup(placement: .navigation) {
//      Self.navigationButtons(store: self.store)
//    }
//
//    ToolbarItemGroup {
//      Self.otherButtons(
//        store: self.store,
//        redactionReasons: redactionReasons
//      )
//    }
//  }
//
//  @ViewBuilder
//  static func navigationButtons(store: Store<State, Action>) -> some View {
//    CommonToolbarNavigation()
//
//    IfLetStore(store.scope(state: { $0.userInfos[$0.chatId] })) { store in
//      ToolbarDivider()
//
//      WithViewStore(store) { viewStore in
//        ToolbarTitle(
//          name: viewStore.name,
//          // TODO: Make this dynamic
//          status: .available
//        )
//      }
//    }
//  }
//
//  @ViewBuilder
//  static func otherButtons(
//    store: Store<State, Action>,
//    redactionReasons: RedactionReasons
//  ) -> some View {
//    IfLetStore(store.scope(state: { $0.userInfos[$0.chatId] })) { store in
//      WithViewStore(store) { viewStore in
//        ToolbarSecurity(
//          jid: viewStore.jid,
//          // TODO: Make this dynamic
//          isVerified: false
//        )
//
//        ToolbarDivider()
//      }
//    }
//
//    Self.actionItems(store: store, redactionReasons: redactionReasons)
//
//    ToolbarDivider()
//
//    CommonToolbarActions()
//  }
//
//  static func actionItems(
//    store: Store<State, Action>,
//    redactionReasons: RedactionReasons
//  ) -> some View {
//    WithViewStore(store) { viewStore in
//      Button { viewStore.send(.startVideoCallTapped) } label: {
//        Label("Video", systemImage: "video")
//      }
//      // https://github.com/prose-im/prose-app-macos/issues/48
//      .disabled(true)
//
//      Toggle(isOn: viewStore.binding(\State.$isShowingInfo).animation()) {
//        Label("Info", systemImage: "info.circle")
//      }
//      .disabled(viewStore.childState.user == nil)
//    }
//    .unredacted()
//    .disabled(redactionReasons.contains(.placeholder))
//  }
// }
