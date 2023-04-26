//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import ComposableArchitecture
import CredentialsClient
import ProseCore

public struct AuthenticationReducer: ReducerProtocol {
  public struct State: Equatable {
    var route = Route.basicAuth(.init())

    public init() {}
  }

  public enum Action: Equatable {
    public enum Delegate: Equatable {
      case didLogIn
    }

    case basicAuth(BasicAuthReducer.Action)
    case profile(ProfileReducer.Action)
    case delegate(Delegate)
  }

  public enum Route: Equatable {
    case basicAuth(BasicAuthReducer.State)
    case profile(ProfileReducer.State)
  }

  private enum EffectToken: Hashable, CaseIterable {
    case saveCredentials
  }

  public init() {}

  @Dependency(\.accountBookmarksClient) var accountBookmarks
  @Dependency(\.accountsClient) var accounts
  @Dependency(\.credentialsClient) var credentials

  public var body: some ReducerProtocol<State, Action> {
    self.core

    Scope(state: \.route, action: /.self) {
      EmptyReducer()
        .ifCaseLet(/Route.basicAuth, action: /Action.basicAuth) {
          BasicAuthReducer()
        }
        .ifCaseLet(/Route.profile, action: /Action.profile) {
          ProfileReducer()
        }
    }
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case let .basicAuth(.loginResult(.success(userData))):
        state.route = .profile(.init(userData: userData))
        return .none

      case let .profile(.saveProfileResult(.success(credentials))):
        return .task {
          // While it wouldn't be great if we couldn't save the credentials and bookmark, the app
          // would still be usable thus try?.
          try? self.credentials.save(credentials)
          try? await self.accountBookmarks.addBookmark(credentials.jid)
          try self.accounts.promoteEphemeralAccount(credentials.jid)
          return .delegate(.didLogIn)
        }.cancellable(id: EffectToken.saveCredentials)

      case .basicAuth, .profile, .delegate:
        return .none
      }
    }
  }
}
