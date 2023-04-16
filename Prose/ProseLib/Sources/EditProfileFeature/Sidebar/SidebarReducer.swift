//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import ProseCoreTCA
import TCAUtils

public struct SidebarReducer: ReducerProtocol {
  public typealias State = SessionState<SidebarState>

  public struct SidebarState: Equatable {
    var header = SidebarHeaderReducer.SidebarHeaderState()
    var rows: IdentifiedArrayOf<SidebarRowReducer.State> = [
      .init(
        id: .identity,
        icon: "person.text.rectangle",
        headline: L10n.EditProfile.Sidebar.Identity.label,
        subheadline: L10n.EditProfile.Sidebar.Identity.sublabel,
        isSelected: true
      ),
      .init(
        id: .authentication,
        icon: "lock",
        headline: L10n.EditProfile.Sidebar.Authentication.label,
        subheadline: L10n.EditProfile.Sidebar.Authentication.sublabel
      ),
      .init(
        id: .profile,
        icon: "person",
        headline: L10n.EditProfile.Sidebar.Profile.label,
        subheadline: L10n.EditProfile.Sidebar.Profile.sublabel
      ),
      .init(
        id: .encryption,
        icon: "key",
        headline: L10n.EditProfile.Sidebar.Encryption.label,
        subheadline: L10n.EditProfile.Sidebar.Encryption.sublabel
      ),
    ]

    @BindingState var selection: Selection? = .identity
  }

  public enum Action: Equatable, BindableAction {
    case header(SidebarHeaderReducer.Action)
    case row(id: Selection, SidebarRowReducer.Action)
    case binding(BindingAction<SessionState<SidebarState>>)
  }

  public enum Selection: Equatable {
    case identity, authentication, profile, encryption
  }

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
      .onChange(of: \.selection) { previousSelection, newSelection, state, _ in
        if let previousSelection = previousSelection {
          state.rows[id: previousSelection]?.isSelected = false
        }
        if let newSelection = newSelection {
          state.rows[id: newSelection]?.isSelected = true
        }
        return .none
      }
    Scope(state: \.header, action: /Action.header) {
      SidebarHeaderReducer()
    }
    EmptyReducer()
      .forEach(\.rows, action: /Action.row) {
        SidebarRowReducer()
      }
  }
}

private extension SidebarReducer.State {
  var header: SidebarHeaderReducer.State {
    get { self.get(\.header) }
    set { self.set(\.header, newValue) }
  }
}
