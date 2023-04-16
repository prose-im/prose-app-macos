//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import SwiftUI

struct SidebarRow: View {
  let store: StoreOf<SidebarRowReducer>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      Self.content(viewStore: viewStore)
    }
  }

  @ViewBuilder
  static func content(viewStore: ViewStoreOf<SidebarRowReducer>) -> some View {
    let foregroundColor = viewStore.foregroundColor
    HStack {
      ZStack {
        Circle()
          .fill(viewStore.isSelected ? Color.white : Color.accentColor)
        Image(systemName: viewStore.icon)
      }
      .symbolVariant(.fill)
      .foregroundColor(viewStore.isSelected ? Color.accentColor : Color.white)
      .frame(width: 24, height: 24)
      .accessibilityHidden(true)
      VStack(alignment: .leading, spacing: 0) {
        Text(verbatim: viewStore.headline)
        Text(verbatim: viewStore.subheadline)
          .font(.subheadline)
          .foregroundColor(foregroundColor.opacity(0.75))
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(
        L10n.EditProfile.Sidebar.Row
          .axLabel(viewStore.headline, viewStore.subheadline)
      )
      Image(systemName: "chevron.forward.circle.fill")
        .symbolVariant(.fill)
        .foregroundColor(viewStore.isSelected ? .white : .primary)
        .opacity(viewStore.isSelected ? 1 : 0)
        .accessibilityHidden(true)
    }
    .font(.headline)
    .padding(.vertical, 4)
    .padding(.horizontal, 8)
    .foregroundColor(foregroundColor)
    .tag(viewStore.id)
    .accessibilityElement(children: .combine)
    .accessibilityAddTraits(viewStore.isSelected ? .isSelected : [])
  }
}
