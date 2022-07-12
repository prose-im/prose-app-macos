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
      Button { viewStore.send(.rowTapped) } label: { Self.content(viewStore: viewStore) }
        .buttonStyle(.plain)
        .onHover { viewStore.send(.onHover($0)) }
    }
  }

  @ViewBuilder
  static func content(viewStore: ViewStore<ViewState, ViewAction>) -> some View {
    let foregroundColor = viewStore.foregroundColor
    let backgroundOpacity = viewStore.backgroundOpacity
    ZStack {
      RoundedRectangle(cornerRadius: 4)
        .fill(Color.blue)
        .opacity(backgroundOpacity)
      HStack {
        ZStack {
          Circle()
            .fill(viewStore.isSelected ? Color.white : Color.blue)
          Image(systemName: viewStore.icon)
        }
        .symbolVariant(.fill)
        .foregroundColor(viewStore.isSelected ? Color.blue : Color.white)
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
          .opacity(viewStore.isSelected || viewStore.isHovered ? 1 : 0)
          .accessibilityHidden(true)
      }
      .font(.headline)
      .padding(.vertical, 4)
      .padding(.horizontal, 8)
    }
    .foregroundColor(foregroundColor)
    .accessibilityElement(children: .combine)
    .accessibilityAddTraits(viewStore.isSelected ? .isSelected : [])
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let sidebarRowReducer = Reducer<
  SidebarRowState,
  SidebarRowAction,
  Void
> { state, action, _ in
  switch action {
  case let .onHover(isHovered):
    state.isHovered = isHovered
    return .none

  case .rowTapped, .binding:
    return .none
  }
}.binding()

// MARK: State

public struct SidebarRowState: Equatable, Identifiable {
  public let id: SidebarState.Selection

  let icon: String
  let headline: String
  let subheadline: String
  var isSelected: Bool
  var isHovered: Bool

  var foregroundColor: Color { self.isSelected ? .white : .primary }
  var backgroundOpacity: CGFloat {
    switch (self.isSelected, self.isHovered) {
    case (true, _): return 1
    case (false, true): return 0.125
    default: return 0
    }
  }

  public init(
    id: SidebarState.Selection,
    icon: String,
    headline: String,
    subheadline: String,
    isSelected: Bool = false,
    isHovered: Bool = false
  ) {
    self.id = id
    self.icon = icon
    self.headline = headline
    self.subheadline = subheadline
    self.isSelected = isSelected
    self.isHovered = isHovered
  }
}

// MARK: Actions

public enum SidebarRowAction: Equatable, BindableAction {
  case rowTapped
  case onHover(Bool)
  case binding(BindingAction<SidebarRowState>)
}

// MARK: - Previews

struct SidebarRow_Previews: PreviewProvider {
  static var previews: some View {
    VStack(alignment: .leading, spacing: 4) {
      self.preview(state: .init(
        id: .identity,
        icon: "person.text.rectangle",
        headline: "Identity",
        subheadline: "Name, Phone, Email",
        isSelected: true
      ))
      self.preview(state: .init(
        id: .authentication,
        icon: "lock",
        headline: "Authentication",
        subheadline: "Password, MFA",
        isSelected: true,
        isHovered: true
      ))
      self.preview(state: .init(
        id: .profile,
        icon: "person",
        headline: "Profile",
        subheadline: "Job, Location",
        isHovered: true
      ))
      self.preview(state: .init(
        id: .encryption,
        icon: "key",
        headline: "Encryption",
        subheadline: "Certificates, Keys"
      ))
    }
    .padding()
    .fixedSize()
  }

  static func preview(state: SidebarRowState) -> some View {
    SidebarRow(store: Store(
      initialState: state,
      reducer: sidebarRowReducer,
      environment: ()
    ))
  }
}
