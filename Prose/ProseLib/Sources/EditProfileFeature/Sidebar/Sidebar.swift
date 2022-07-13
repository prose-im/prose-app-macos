//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import IdentifiedCollections
import SwiftUI

private let l10n = L10n.EditProfile.Sidebar.self

// MARK: - View

struct Sidebar: View {
  typealias ViewState = SidebarState
  typealias ViewAction = SidebarAction

  let store: Store<ViewState, ViewAction>

  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack(alignment: .leading) {
        WithViewStore(self.store.scope(state: \ViewState.selection)) { _ in
          ForEachStore(
            self.store.scope(state: \.rows, action: ViewAction.row),
            content: SidebarRow.init(store:)
          )
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(16)
      .fixedSize()
    }
    .safeAreaInset(edge: .top, spacing: 0) {
      SidebarHeader(store: self.store.scope(state: \.header, action: ViewAction.header))
        .padding([.horizontal, .top], 24)
        .padding(.bottom, 8)
    }
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let sidebarReducer = Reducer<
  SidebarState,
  SidebarAction,
  Void
>.combine([
  sidebarHeaderReducer.pullback(
    state: \SidebarState.header,
    action: CasePath(SidebarAction.header),
    environment: { $0 }
  ),
  sidebarRowReducer.forEach(
    state: \SidebarState.rows,
    action: CasePath(SidebarAction.row),
    environment: { $0 }
  ),
  Reducer { state, action, _ in
    switch action {
    case let .row(id, .rowTapped):
      state.rows[id: state.selection]?.isSelected = false
      state.rows[id: id]?.isSelected = true
      state.selection = id
      return .none

    default:
      return .none
    }
  }.binding(),
])

// MARK: State

public struct SidebarState: Equatable {
  var header: SidebarHeaderState
  var rows: IdentifiedArrayOf<SidebarRowState> = [
    .init(
      id: .identity,
      icon: "person.text.rectangle",
      headline: l10n.Identity.label,
      subheadline: l10n.Identity.sublabel
    ),
    .init(
      id: .authentication,
      icon: "lock",
      headline: l10n.Authentication.label,
      subheadline: l10n.Authentication.sublabel
    ),
    .init(
      id: .profile,
      icon: "person",
      headline: l10n.Profile.label,
      subheadline: l10n.Profile.sublabel
    ),
    .init(
      id: .encryption,
      icon: "key",
      headline: l10n.Encryption.label,
      subheadline: l10n.Encryption.sublabel
    ),
  ]

  public internal(set) var selection: Selection

  public init(
    header: SidebarHeaderState,
    selection: Selection
  ) {
    self.header = header
    self.selection = selection
    self.rows[id: selection]?.isSelected = true
  }
}

public extension SidebarState {
  enum Selection: Equatable {
    case identity, authentication, profile, encryption
  }
}

// MARK: Actions

public enum SidebarAction: Equatable, BindableAction {
  case header(SidebarHeaderAction), row(id: SidebarState.Selection, SidebarRowAction)
  case binding(BindingAction<SidebarState>)
}

// MARK: - Previews

struct Sidebar_Previews: PreviewProvider {
  static var previews: some View {
    Sidebar(store: Store(
      initialState: SidebarState(
        header: .init(),
        selection: .identity
      ),
      reducer: sidebarReducer,
      environment: ()
    ))
  }
}
