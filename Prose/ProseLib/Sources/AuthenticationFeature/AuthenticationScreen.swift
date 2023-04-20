//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import ComposableArchitecture
import CredentialsClient
import SwiftUI

public struct AuthenticationScreen: View {
  public typealias State = AuthenticationReducer.State
  public typealias Action = AuthenticationReducer.Action

  private let store: Store<State, Action>
  private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

  public init(store: Store<State, Action>) {
    self.store = store
  }

  public var body: some View {
    SwitchStore(self.store.scope(state: \State.route)) {
      CaseLet(
        state: /AuthenticationReducer.Route.basicAuth,
        action: Action.basicAuth,
        then: BasicAuthView.init(store:)
      )
    }
    .frame(minWidth: 400)
  }
}

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
