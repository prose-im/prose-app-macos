//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import struct AuthenticationFeature.AuthenticationReducer
import ComposableArchitecture
import EditProfileFeature

#warning("Fix popover dismiss animation")
// Currently we're seeing a warning when the "Edit Profile" button in the AccountSettings popover
// was pressed, since the route immediately switches to .editProfile which pulls the state out
// from under the AccountSettings popover. The swift-composable-presentation project solves this
// here: https://github.com/darrarski/swift-composable-presentation/blob/main/Sources/ComposablePresentation/ReplayNonNil.swift
// Let's wait though for the impending TCA navigation library to see what they have in store.

public struct FooterReducer: ReducerProtocol {
  public typealias State = SessionState<FooterState>

  public struct FooterState: Equatable {
    var route: Route?
    var teamName = "<Unknown>"
    var statusIcon = Character("🚀")
    var statusMessage = "<Unimplemented>"

    public init() {}
  }

  public enum Action: Equatable {
    case setRoute(Route.Tag)
    case dismiss(Route.Tag)

    case accountSettingsMenu(AccountSettingsMenuReducer.Action)
    case accountSwitcherMenu(AccountSwitcherMenuReducer.Action)
    case auth(AuthenticationReducer.Action)
    case editProfile(EditProfileReducer.Action)
  }

  public enum Route: Equatable {
    case accountSettingsMenu(AccountSettingsMenuReducer.AccountSettingsMenuState)
    case accountSwitcherMenu(AccountSwitcherMenuReducer.State)
    case auth(AuthenticationReducer.State)
    case editProfile(EditProfileReducer.State)
  }

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    EmptyReducer()
      .ifLet(\.sessionRoute, action: /.self) {
        EmptyReducer()
          .ifLet(\.accountSettingsMenu, action: /Action.accountSettingsMenu) {
            AccountSettingsMenuReducer()
          }
      }
    EmptyReducer()
      .ifLet(\.route, action: /.self) {
        EmptyReducer()
          .ifCaseLet(/Route.accountSwitcherMenu, action: /Action.accountSwitcherMenu) {
            AccountSwitcherMenuReducer()
          }
          .ifCaseLet(/Route.auth, action: /Action.auth) {
            AuthenticationReducer()
          }
          .ifCaseLet(/Route.editProfile, action: /Action.editProfile) {
            EditProfileReducer()
          }
      }

    self.core
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .setRoute(.accountSettingsMenu):
        state.route = .accountSettingsMenu(.init(statusIcon: state.statusIcon))
        return .none

      case .setRoute(.accountSwitcherMenu):
        state.route = .accountSwitcherMenu(state.get { _ in .init() })
        return .none

      case .setRoute(.editProfile), .accountSettingsMenu(.editProfileTapped):
        state.route = .editProfile(state.get { _ in .init() })
        return .none

      case .setRoute(.auth):
        return .none

      case let .dismiss(route) where state.route?.tag == route:
        state.route = nil
        return .none

      case .editProfile(.cancelTapped):
        state.route = nil
        return .none

      case .accountSwitcherMenu(.connectAccountTapped):
        state.route = .auth(.init())
        return .none

      case let .accountSwitcherMenu(.accountSelected(jid)):
        state.route = nil
        state.currentUser = jid
        return .none

      case .auth(.delegate(.didLogIn)):
        state.route = nil
        return .none

      case .accountSettingsMenu, .accountSwitcherMenu, .editProfile, .dismiss, .auth:
        return .none
      }
    }
  }
}

extension FooterReducer.Route {
  public enum Tag: Equatable {
    case accountSettingsMenu
    case accountSwitcherMenu
    case auth
    case editProfile
  }

  var tag: Tag {
    switch self {
    case .accountSettingsMenu:
      return .accountSettingsMenu
    case .accountSwitcherMenu:
      return .accountSwitcherMenu
    case .auth:
      return .auth
    case .editProfile:
      return .editProfile
    }
  }
}

extension FooterReducer.State {
  var sessionRoute: SessionState<FooterReducer.Route>? {
    get { self.get(\.route) }
    set { self.set(\.route, newValue) }
  }
}

extension SessionState<FooterReducer.Route> {
  var accountSettingsMenu: AccountSettingsMenuReducer.State? {
    get { self.get(/FooterReducer.Route.accountSettingsMenu) }
    set { self.set(/FooterReducer.Route.accountSettingsMenu, newValue) }
  }
}
