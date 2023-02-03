//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import IdentifiedCollections
import ProseCoreTCA
import SwiftUI

private let l10n = L10n.EditProfile.Sidebar.self

// MARK: - View

struct Sidebar: View {
  typealias ViewState = SessionState<SidebarState>
  typealias ViewAction = SidebarAction

  static let minWidth: CGFloat = 228

  let store: Store<ViewState, ViewAction>

  var body: some View {
    WithViewStore(self.store, removeDuplicates: { $0.selection == $1.selection }) { viewStore in
      List(selection: viewStore.binding(\.$selection)) {
        ForEachStore(
          self.store.scope(state: \.rows, action: ViewAction.row),
          content: SidebarRow.init(store:)
        )
      }
      .listStyle(.sidebar)
      .frame(minWidth: Self.minWidth)
    }
    .safeAreaInset(edge: .top, spacing: 0) {
      SidebarHeader(store: self.store.scope(state: \.scoped.header, action: ViewAction.header))
        .padding([.horizontal, .top], 24)
        .padding(.bottom, 8)
    }
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

let sidebarReducer = AnyReducer<
  SessionState<SidebarState>,
  SidebarAction,
  SidebarEnvironment
>.combine([
  sidebarHeaderReducer.pullback(
    state: \.header,
    action: CasePath(SidebarAction.header),
    environment: \.header
  ),
  sidebarRowReducer.forEach(
    state: \.rows,
    action: CasePath(SidebarAction.row),
    environment: { _ in }
  ),
  AnyReducer.empty.binding()
    .onChange(of: \.selection) { previousSelection, newSelection, state, _, _ in
      if let previousSelection = previousSelection {
        state.rows[id: previousSelection]?.isSelected = false
      }
      if let newSelection = newSelection {
        state.rows[id: newSelection]?.isSelected = true
      }
      return .none
    },
])

struct SidebarEnvironment {
  var proseClient: ProseClient
  var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(proseClient: ProseClient, mainQueue: AnySchedulerOf<DispatchQueue>) {
    self.proseClient = proseClient
    self.mainQueue = mainQueue
  }
}

extension SidebarEnvironment {
  var header: SidebarHeaderEnvironment {
    SidebarHeaderEnvironment(proseClient: self.proseClient, mainQueue: self.mainQueue)
  }
}

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

  @BindingState public internal(set) var selection: Selection?

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

private extension SessionState where ChildState == SidebarState {
  var header: SessionState<SidebarHeaderState> {
    get { self.get(\.header) }
    set { self.set(\.header, newValue) }
  }
}

// MARK: Actions

public enum SidebarAction: Equatable, BindableAction {
  case header(SidebarHeaderAction), row(id: SidebarState.Selection, SidebarRowAction)
  case binding(BindingAction<SessionState<SidebarState>>)
}

// MARK: - Previews

#if DEBUG
  struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
      Sidebar(store: Store(
        initialState: .mock(SidebarState(
          header: .init(),
          selection: .identity
        )),
        reducer: sidebarReducer,
        environment: SidebarEnvironment(proseClient: .noop, mainQueue: .main)
      ))
      .frame(maxWidth: 300)
    }
  }
#endif
