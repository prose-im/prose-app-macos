//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import ComposableArchitecture
import CredentialsClient

public struct AuthenticationReducer: ReducerProtocol {
  public struct State: Equatable {
    var route = Route.basicAuth(.init())

    public init() {}
  }

  public enum Action: Equatable {
    case didLogIn(BareJid)
    case basicAuth(BasicAuthReducer.Action)
    // case mfa(MFAAction)
  }

  public enum Route: Equatable {
    case basicAuth(BasicAuthReducer.State)
    // case mfa(MFAState)
  }

  public init() {}

  @Dependency(\.credentialsClient) var credentials

  public var body: some ReducerProtocol<State, Action> {
    self.core

    Scope(state: \.route, action: /.self) {
      EmptyReducer()
        .ifCaseLet(/Route.basicAuth, action: /Action.basicAuth) {
          BasicAuthReducer()
        }
    }
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerProtocol<State, Action> {
    Reduce { _, action in
      guard case let .basicAuth(.loginResult(.success(jid))) = action else {
        return .none
      }
      return .task { .didLogIn(jid) }
    }
  }
}
