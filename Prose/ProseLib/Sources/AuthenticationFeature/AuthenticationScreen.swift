//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import ComposableArchitecture
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
