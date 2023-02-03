//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import ProseCoreTCA
import SwiftUI
import TcaHelpers

private let l10n = L10n.EditProfile.self

// MARK: - View

public struct EditProfileScreen: View {
  public typealias ViewState = SessionState<EditProfileState>
  public typealias ViewAction = EditProfileAction

  static let minContentWidth: CGFloat = 480

  let store: Store<ViewState, ViewAction>

  public init(store: Store<ViewState, ViewAction>) {
    self.store = store
  }

  public var body: some View {
    NavigationView {
      Sidebar(store: self.store.scope(state: \.sidebar, action: ViewAction.sidebar))
      detailView()
        .frame(minWidth: Self.minContentWidth, minHeight: 512)
        .safeAreaInset(edge: .bottom, alignment: .trailing) {
          HStack {
            WithViewStore(
              self.store
                .scope(state: \.childState.isSaveProfileButtonDisabled)
            ) { viewStore in
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
    // NOTE: +1 for the separator width…
    .frame(minWidth: Self.minContentWidth + Sidebar.minWidth + 1)
  }

  func detailView() -> some View {
    IfLetStore(self.store.scope(state: \.route)) { store in
      SwitchStore(store) {
        CaseLet(
          state: CasePath(EditProfileState.Route.identity).extract,
          action: ViewAction.identity,
          then: IdentityView.init(store:)
        )
        CaseLet(
          state: CasePath(EditProfileState.Route.authentication).extract,
          action: ViewAction.authentication,
          then: AuthenticationView.init(store:)
        )
        CaseLet(
          state: CasePath(EditProfileState.Route.profile).extract,
          action: ViewAction.profile,
          then: ProfileView.init(store:)
        )
        CaseLet(
          state: CasePath(EditProfileState.Route.encryption).extract,
          action: ViewAction.encryption,
          then: EncryptionView.init(store:)
        )
      }
    }
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let editProfileReducer = AnyReducer<
  SessionState<EditProfileState>,
  EditProfileAction,
  EditProfileEnvironment
>.combine([
  sidebarReducer.pullback(
    state: \.sidebar,
    action: CasePath(EditProfileAction.sidebar),
    environment: \.sidebar
  ),
  identityReducer._pullback(
    state: (\SessionState<EditProfileState>.route).case(CasePath(EditProfileState.Route.identity)),
    action: CasePath(EditProfileAction.identity),
    environment: { _ in () }
  ),
  authenticationReducer._pullback(
    state: (\SessionState<EditProfileState>.route)
      .case(CasePath(EditProfileState.Route.authentication)),
    action: CasePath(EditProfileAction.authentication),
    environment: { _ in () }
  ),
  profileReducer._pullback(
    state: (\SessionState<EditProfileState>.route).case(CasePath(EditProfileState.Route.profile)),
    action: CasePath(EditProfileAction.profile),
    environment: { _ in () }
  ),
  encryptionReducer._pullback(
    state: (\SessionState<EditProfileState>.route)
      .case(CasePath(EditProfileState.Route.encryption)),
    action: CasePath(EditProfileAction.encryption),
    environment: { _ in () }
  ),
  AnyReducer { _, action, _ in
    switch action {
    case .saveProfileTapped:
      logger.trace("Save profile tapped")
      return .none

    case .cancelTapped:
      logger.trace("Cancel profile editing tapped")
      return .none

    case .sidebar, .identity, .authentication, .profile, .encryption:
      return .none
    }
  },
])
.onChange(of: \.sidebar.childState.selection) { selection, state, _, _ in
  state.route = EditProfileState.route(for: selection)
  return .none
}

// MARK: State

public struct EditProfileState: Equatable {
  var route: Route?

  var sidebar: SidebarState

  var isSaveProfileButtonDisabled: Bool {
    switch self.route {
    case .identity, .profile:
      return false
    case .authentication, .encryption, .none:
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

  static func route(for selection: SidebarState.Selection?) -> Route? {
    switch selection {
    case .none:
      return nil
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

private extension SessionState where ChildState == EditProfileState {
  var sidebar: SessionState<SidebarState> {
    get { self.get(\.sidebar) }
    set { self.set(\.sidebar, newValue) }
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
  var proseClient: ProseClient
  var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(proseClient: ProseClient, mainQueue: AnySchedulerOf<DispatchQueue>) {
    self.proseClient = proseClient
    self.mainQueue = mainQueue
  }
}

extension EditProfileEnvironment {
  var sidebar: SidebarEnvironment {
    SidebarEnvironment(proseClient: self.proseClient, mainQueue: self.mainQueue)
  }
}

// MARK: - Previews

#if DEBUG
  struct EditProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
      EditProfileScreen(store: Store(
        initialState: .mock(EditProfileState(
          sidebarHeader: .init(),
          route: .identity(.init())
        )),
        reducer: editProfileReducer,
        environment: EditProfileEnvironment(proseClient: .noop, mainQueue: .main)
      ))
    }
  }
#endif
