//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import CursorClient
import SwiftUI
import TcaHelpers

private let l10n = L10n.EditProfile.self

// MARK: - View

public struct EditProfileScreen: View {
  public typealias ViewState = EditProfileState
  public typealias ViewAction = EditProfileAction

  let store: Store<ViewState, ViewAction>

  public init(store: Store<ViewState, ViewAction>) {
    self.store = store
  }

  public var body: some View {
    NavigationView {
      Sidebar(store: self.store.scope(state: \.sidebar, action: ViewAction.sidebar))
      detailView()
        .frame(minWidth: 480, minHeight: 512)
        .safeAreaInset(edge: .bottom, alignment: .trailing) {
          HStack {
            WithViewStore(self.store.scope(state: \.isSaveProfileButtonDisabled)) { viewStore in
              Button(l10n.CancelAction.label) { viewStore.send(.cancelTapped) }
              Button(l10n.SaveProfileAction.label) { viewStore.send(.saveProfileTapped) }
                .buttonStyle(.borderedProminent)
                .disabled(viewStore.state)
            }
          }
          .controlSize(.large)
          .padding(4)
          .background {
            RoundedRectangle(cornerRadius: 8)
              .fill(Material.regular)
          }
          .padding([.horizontal, .bottom])
          // Make sure accessibility frame isn't inset by the window's rounded corners
          .contentShape(Rectangle())
          // Make footer have a higher priority, to be accessible over the scroll view
          .accessibilitySortPriority(1)
        }
    }
  }

  func detailView() -> some View {
    SwitchStore(self.store.scope(state: \.route)) {
      CaseLet(
        state: CasePath(ViewState.Route.identity).extract,
        action: ViewAction.identity,
        then: IdentityView.init(store:)
      )
      CaseLet(
        state: CasePath(ViewState.Route.authentication).extract,
        action: ViewAction.authentication,
        then: AuthenticationView.init(store:)
      )
      CaseLet(
        state: CasePath(ViewState.Route.profile).extract,
        action: ViewAction.profile,
        then: ProfileView.init(store:)
      )
      CaseLet(
        state: CasePath(ViewState.Route.encryption).extract,
        action: ViewAction.encryption,
        then: EncryptionView.init(store:)
      )
    }
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let editProfileReducer = Reducer<
  EditProfileState,
  EditProfileAction,
  EditProfileEnvironment
>.combine([
  sidebarReducer.pullback(
    state: \EditProfileState.sidebar,
    action: CasePath(EditProfileAction.sidebar),
    environment: { $0 }
  ),
  Reducer { _, action, _ in
    switch action {
    case .saveProfileTapped:
      logger.trace("Save profile tapped")
      return .none

    case .cancelTapped:
      logger.trace("Cancel profile editing tapped")
      return .none

    default:
      return .none
    }
  },
])
.onChange(of: \.sidebar.selection) { selection, state, _, _ in
  state.route = EditProfileState.route(for: selection)
  return .none
}

// MARK: State

public struct EditProfileState: Equatable {
  var route: Route

  var sidebar: SidebarState

  var isSaveProfileButtonDisabled: Bool {
    switch self.route {
    case .identity, .profile:
      return false
    case .authentication, .encryption:
      return true
    }
  }

  public init(
    sidebarHeader: SidebarHeaderState,
    route: Route
  ) {
    self.route = route

    switch route {
    case .identity:
      self.sidebar = .init(header: sidebarHeader, selection: .identity)
    case .authentication:
      self.sidebar = .init(header: sidebarHeader, selection: .authentication)
    case .profile:
      self.sidebar = .init(header: sidebarHeader, selection: .profile)
    case .encryption:
      self.sidebar = .init(header: sidebarHeader, selection: .encryption)
    }
  }
}

public extension EditProfileState {
  enum Route: Equatable {
    case identity(IdentityState)
    case authentication(AuthenticationState)
    case profile(ProfileState)
    case encryption(EncryptionState)
  }

  static func route(for selection: SidebarState.Selection) -> Route {
    switch selection {
    case .identity:
      return .identity(.init())
    case .authentication:
      return .authentication(.init())
    case .profile:
      return .profile(.init())
    case .encryption:
      return .encryption(.init())
    }
  }
}

// MARK: Actions

public enum EditProfileAction: Equatable {
  case saveProfileTapped, cancelTapped
  case sidebar(SidebarAction)
  case identity(IdentityAction)
  case authentication(AuthenticationAction)
  case profile(ProfileAction)
  case encryption(EncryptionAction)
}

// MARK: Environment

public struct EditProfileEnvironment {
  var cursorClient: CursorClient
}

public extension EditProfileEnvironment {
  static func live() -> EditProfileEnvironment {
    EditProfileEnvironment(
      cursorClient: .live()
    )
  }
}

// MARK: - Previews

struct EditProfileScreen_Previews: PreviewProvider {
  static var previews: some View {
    EditProfileScreen(store: Store(
      initialState: EditProfileState(
        sidebarHeader: .init(),
        route: .identity(.init())
      ),
      reducer: editProfileReducer,
      environment: .live()
    ))
  }
}
