//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import SwiftUI

private let l10n = L10n.EditProfile.Sidebar.Row.self

// MARK: - View

struct SidebarRow: View {
  typealias ViewState = SidebarRowState
  typealias ViewAction = SidebarRowAction

  let store: Store<ViewState, ViewAction>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      Self.content(viewStore: viewStore)
    }
  }

  @ViewBuilder
  static func content(viewStore: ViewStore<ViewState, ViewAction>) -> some View {
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
      .accessibilityLabel(l10n.axLabel(viewStore.headline, viewStore.subheadline))
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

// MARK: - The Composable Architecture

// MARK: Reducer

public let sidebarRowReducer = AnyReducer<
  SidebarRowState,
  SidebarRowAction,
  Void
>.empty.binding()

// MARK: State

public struct SidebarRowState: Equatable, Identifiable {
  public let id: SidebarState.Selection

  let icon: String
  let headline: String
  let subheadline: String
  var isSelected: Bool

  var foregroundColor: Color { self.isSelected ? .white : .primary }

  public init(
    id: SidebarState.Selection,
    icon: String,
    headline: String,
    subheadline: String,
    isSelected: Bool = false
  ) {
    self.id = id
    self.icon = icon
    self.headline = headline
    self.subheadline = subheadline
    self.isSelected = isSelected
  }
}

// MARK: Actions

public enum SidebarRowAction: Equatable, BindableAction {
  case binding(BindingAction<SidebarRowState>)
}

// MARK: - Previews

struct SidebarRow_Previews: PreviewProvider {
  struct Preview: View {
    @State private var selection: SidebarState.Selection? = .identity

    var body: some View {
      List(selection: self.$selection) {
        Self.preview(state: .init(
          id: .identity,
          icon: "person.text.rectangle",
          headline: "Identity",
          subheadline: "Name, Phone, Email",
          isSelected: selection == .identity
        ))
        Self.preview(state: .init(
          id: .authentication,
          icon: "lock",
          headline: "Authentication",
          subheadline: "Password, MFA",
          isSelected: selection == .authentication
        ))
        Self.preview(state: .init(
          id: .profile,
          icon: "person",
          headline: "Profile",
          subheadline: "Job, Location",
          isSelected: selection == .profile
        ))
        Self.preview(state: .init(
          id: .encryption,
          icon: "key",
          headline: "Encryption",
          subheadline: "Certificates, Keys",
          isSelected: selection == .encryption
        ))
      }
      .listStyle(.sidebar)
      .frame(maxWidth: 300)
    }

    static func preview(state: SidebarRowState) -> some View {
      SidebarRow(store: Store(
        initialState: state,
        reducer: sidebarRowReducer,
        environment: ()
      ))
    }
  }

  static var previews: some View {
    Preview()
  }
}
