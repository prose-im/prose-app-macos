//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppDomain
import ComposableArchitecture
import CredentialsClient
import SwiftUI
import TcaHelpers

public struct AuthenticationScreen: View {
  public typealias State = Authentication.State
  public typealias Action = Authentication.Action

  private let store: Store<State, Action>
  private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

  public init(store: Store<State, Action>) {
    self.store = store
  }

  public var body: some View {
    SwitchStore(self.store.scope(state: \State.route)) {
      CaseLet(
        state: /Authentication.Route.basicAuth,
        action: Action.basicAuth,
        then: BasicAuthView.init(store:)
      )
      #warning("FIXME")
//      CaseLet(
//        state: /Authentication.Route.mfa,
//        action: Action.mfa,
//        then: MFAView.init(store:)
//      )
    }
    .frame(minWidth: 400)
  }
}

public struct Authentication: ReducerProtocol {
  public struct State: Equatable {
    var route = Route.basicAuth(.init())

    public init() {}
  }

  public enum Action: Equatable {
    case didLogIn(BareJid)
    case basicAuth(BasicAuth.Action)
    // case mfa(MFAAction)
  }

  public enum Route: Equatable {
    case basicAuth(BasicAuth.State)
    // case mfa(MFAState)
  }

  public init() {}

  @Dependency(\.credentialsClient) var credentials
  @Dependency(\.mainQueue) var mainQueue

  public var body: some ReducerProtocol<State, Action> {
    self.core

    Scope(state: \.route, action: /.self) {
      EmptyReducer()
        .ifCaseLet(/Route.basicAuth, action: /Action.basicAuth) {
          BasicAuth()
        }
      #warning("FIXME")
//        .ifCaseLet(/Route.mfa, action: /Action.mfa) {
//          Reduce(
//            mfaReducer,
//            environment: AuthenticationEnvironment(
//              proseClient: self.legacyProseClient,
//              credentials: self.credentials,
//              mainQueue: self.mainQueue
//            )
//          )
//        }
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
