//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import IdentifiedCollections
import SwiftUI

struct Sidebar: View {
  static let minWidth: CGFloat = 228

  let store: StoreOf<SidebarReducer>

  var body: some View {
    WithViewStore(self.store, removeDuplicates: { $0.selection == $1.selection }) { viewStore in
      List(selection: viewStore.binding(\.$selection)) {
        ForEachStore(
          self.store.scope(state: \.rows, action: SidebarReducer.Action.row),
          content: SidebarRow.init(store:)
        )
      }
      .listStyle(.sidebar)
      .frame(minWidth: Self.minWidth)
    }
    .safeAreaInset(edge: .top, spacing: 0) {
      SidebarHeader(
        store: self.store
          .scope(state: \.scoped.header, action: SidebarReducer.Action.header)
      )
      .padding([.horizontal, .top], 24)
      .padding(.bottom, 8)
    }
  }
}
