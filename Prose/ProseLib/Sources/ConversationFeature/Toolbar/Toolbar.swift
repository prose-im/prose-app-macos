//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import ComposableArchitecture
import ProseUI
import SwiftUI

struct Toolbar: ToolbarContent {
  struct ViewState: Equatable {
    var contact: Contact
    var isShowingInfo: Bool
  }

  @ObservedObject var viewStore: ViewStore<ViewState, ToolbarReducer.Action>

  init(store: StoreOf<ToolbarReducer>) {
    self.viewStore = ViewStore(store.scope(state: ViewState.init))
  }

  var body: some ToolbarContent {
    ToolbarItemGroup(placement: .navigation) {
      CommonToolbarNavigation()

      ContentCommonNameStatusComponent(
        name: self.viewStore.contact.name,
        status: self.viewStore.contact.availability
      )
      .padding(.horizontal, 8)
    }

    ToolbarItemGroup {
      ToolbarSecurity(
        jid: self.viewStore.contact.jid,
        isVerified: false
      )

      ToolbarDivider()

      Button { self.viewStore.send(.startVideoCallTapped) } label: {
        Label("Video", systemImage: "video")
      }
      .disabled(true)

      Toggle(isOn: self.viewStore.binding(
        get: \.isShowingInfo,
        send: ToolbarReducer.Action.toggleInfoButtonTapped
      ).animation()) {
        Label("Info", systemImage: "info.circle")
      }

      ToolbarDivider()

      CommonToolbarActions()
    }
  }
}

extension Toolbar.ViewState {
  init(_ state: ToolbarReducer.State) {
    self.contact = state.contact
    self.isShowingInfo = state.isShowingInfo
  }
}
