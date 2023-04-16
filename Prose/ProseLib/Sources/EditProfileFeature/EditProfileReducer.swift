//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import ProseCoreTCA
import TCAUtils

public struct EditProfileReducer: ReducerProtocol {
  public typealias State = SessionState<EditProfileState>

  public struct EditProfileState: Equatable {
    var route: Route? = .identity(IdentityReducer.State())
    var sidebar = SidebarReducer.SidebarState()

    var isSaveProfileButtonDisabled: Bool {
      switch self.route {
      case .identity, .profile:
        return false
      case .authentication, .encryption, .none:
        return true
      }
    }

    public init() {}
  }

  public enum Action: Equatable {
    case saveProfileTapped, cancelTapped
    case sidebar(SidebarReducer.Action)
    case identity(IdentityReducer.Action)
    case authentication(AuthenticationReducer.Action)
    case profile(ProfileReducer.Action)
    case encryption(EncryptionReducer.Action)
  }

  enum Route: Equatable {
    case identity(IdentityReducer.State)
    case authentication(AuthenticationReducer.State)
    case profile(ProfileReducer.State)
    case encryption(EncryptionReducer.State)
  }

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    Scope(state: \.sidebar, action: /Action.sidebar) {
      SidebarReducer()
    }.onChange(of: \.sidebar.childState.selection) { selection, state, _ in
      state.route = Route.route(for: selection)
      return .none
    }
    Scope(state: \.route, action: /.self) {
      EmptyReducer()
        .ifCaseLet(/Route.identity, action: /Action.identity) {
          IdentityReducer()
        }
        .ifCaseLet(/Route.authentication, action: /Action.authentication) {
          AuthenticationReducer()
        }
        .ifCaseLet(/Route.profile, action: /Action.profile) {
          ProfileReducer()
        }
        .ifCaseLet(/Route.encryption, action: /Action.encryption) {
          EncryptionReducer()
        }
    }
    self.core
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerProtocol<State, Action> {
    Reduce { _, action in
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
    }
  }
}

extension EditProfileReducer.Route {
  static func route(for selection: SidebarReducer.Selection?) -> Self? {
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

extension EditProfileReducer.State {
  var sidebar: SidebarReducer.State {
    get { self.get(\.sidebar) }
    set { self.set(\.sidebar, newValue) }
  }
}
