//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import CredentialsClient
import ProseCoreTCA
import SwiftUI
import TcaHelpers

// MARK: - View

public struct AuthenticationScreen: View {
  public typealias State = AuthenticationState
  public typealias Action = AuthenticationAction

  private let store: Store<State, Action>
  private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

  public init(store: Store<State, Action>) {
    self.store = store
  }

  public var body: some View {
    SwitchStore(self.store.scope(state: \State.route)) {
      CaseLet(
        state: CasePath(AuthRoute.basicAuth).extract(from:),
        action: Action.basicAuth,
        then: BasicAuthView.init(store:)
      )
      CaseLet(
        state: CasePath(AuthRoute.mfa).extract(from:),
        action: Action.mfa,
        then: MFAView.init(store:)
      )
    }
    .frame(minWidth: 400)
  }
}

// MARK: - The Composabe Architecture

// MARK: Reducer

public let authenticationReducer: AnyReducer<
  AuthenticationState,
  AuthenticationAction,
  AuthenticationEnvironment
> = AnyReducer.combine([
  basicAuthReducer._pullback(
    state: (\AuthenticationState.route).case(CasePath(AuthRoute.basicAuth)),
    action: CasePath(AuthenticationAction.basicAuth),
    environment: { $0 }
  ),
  mfaReducer._pullback(
    state: (\AuthenticationState.route).case(CasePath(AuthRoute.mfa)),
    action: CasePath(AuthenticationAction.mfa),
    environment: { $0 }
  ),
  AnyReducer { state, action, _ in
    switch action {
    case let .basicAuth(.didPassChallenge(.success(jid, password))),
         let .mfa(.didPassChallenge(.success(jid, password))):
      return EffectTask(value: .didLogIn(Credentials(jid: jid, password: password)))

    case let .basicAuth(.didPassChallenge(route)),
         let .mfa(.didPassChallenge(route)):
      state.route = route

    default:
      break
    }

    return .none
  },
])

// MARK: State

public struct AuthenticationState: Equatable {
  var route: AuthRoute

  public init(
    route: AuthRoute
  ) {
    self.route = route
  }
}

public enum AuthRoute: Equatable {
  case basicAuth(BasicAuthState)
  case mfa(MFAState)
  case success(jid: JID, password: String)
}

// MARK: Actions

public enum AuthenticationAction: Equatable {
  case didLogIn(Credentials)
  case basicAuth(BasicAuthAction)
  case mfa(MFAAction)
}

// MARK: Environment

public struct AuthenticationEnvironment {
  var proseClient: ProseClient
  var credentials: CredentialsClient
  var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(
    proseClient: ProseClient,
    credentials: CredentialsClient,
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.proseClient = proseClient
    self.credentials = credentials
    self.mainQueue = mainQueue
  }
}

#if DEBUG

  // MARK: - Previews

  internal struct AuthenticationScreen_Previews: PreviewProvider {
    private struct Preview: View {
      var body: some View {
        AuthenticationScreen(store: Store(
          initialState: AuthenticationState(route: .basicAuth(.init())),
          reducer: authenticationReducer,
          environment: AuthenticationEnvironment(
            proseClient: .noop,
            credentials: .live(service: "org.prose.app.preview.\(Self.self)"),
            mainQueue: .main
          )
        ))
      }
    }

    static var previews: some View {
      Preview()
      Preview()
        .redacted(reason: .placeholder)
        .previewDisplayName("Placeholder")
    }
  }
#endif
