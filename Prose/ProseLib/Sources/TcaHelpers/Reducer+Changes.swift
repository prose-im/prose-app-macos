//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture

// Source: https://github.com/pointfreeco/isowords/blob/244925184babddd477d637bdc216fb34d1d8f88d/Sources/TcaHelpers/OnChange.swift

public extension Reducer {
  func onChange<LocalState>(
    of toLocalState: @escaping (State) -> LocalState,
    perform additionalEffects: @escaping (LocalState, inout State, Action, Environment)
      -> Effect<
        Action, Never
      >
  ) -> Self where LocalState: Equatable {
    .init { state, action, environment in
      let previousLocalState = toLocalState(state)
      let effects = self.run(&state, action, environment)
      let localState = toLocalState(state)

      return previousLocalState != localState
        ? .merge(effects, additionalEffects(localState, &state, action, environment))
        : effects
    }
  }

  /// Runs the provided closure when `LocalState` changes.
  ///
  /// - Parameters:
  ///   - toLocalState: A function that transforms `State` into `LocalState`.
  ///   - predicate: A function to determine when two `LocalState` values are equal.
  ///   - additionalEffects: The closure to run when `LocalState` changed.
  ///   - previousLocalState:  The local state before the change.
  ///   - currentLocalState:  The local state after the change.
  ///   - state:  The current global state.
  ///   - action:  The action that triggered the change.
  ///   - environment:  The environment of dependencies.
  func onChange<LocalState>(
    of toLocalState: @escaping (_ state: State) -> LocalState,
    by predicate: @escaping (
      _ previousLocalState: LocalState,
      _ currentLocalState: LocalState
    ) -> Bool,
    perform additionalEffects: @escaping (
      _ previousLocalState: LocalState,
      _ currentLocalState: LocalState,
      _ state: inout State,
      _ action: Action,
      _ environment: Environment
    ) -> Effect<Action, Never>
  ) -> Self {
    .init { state, action, environment in
      let previousLocalState = toLocalState(state)
      let effects = self.run(&state, action, environment)
      let localState = toLocalState(state)

      return !predicate(previousLocalState, localState)
        ? .merge(
          effects, additionalEffects(
            previousLocalState,
            localState,
            &state,
            action,
            environment
          )
        )
        : effects
    }
  }

  /// Runs the provided closure when `LocalState` changes.
  ///
  /// - Parameters:
  ///   - toLocalState: A function that transforms `State` into `LocalState`.
  ///   - additionalEffects: The closure to run when `LocalState` changed.
  ///   - previousLocalState:  The local state before the change.
  ///   - currentLocalState:  The local state after the change.
  ///   - state:  The current global state.
  ///   - action:  The action that triggered the change.
  ///   - environment:  The environment of dependencies.
  func onChange<LocalState>(
    of toLocalState: @escaping (_ state: State) -> LocalState,
    perform additionalEffects: @escaping (
      _ previousLocalState: LocalState,
      _ currentLocalState: LocalState,
      _ state: inout State,
      _ action: Action,
      _ environment: Environment
    ) -> Effect<Action, Never>
  ) -> Self where LocalState: Equatable {
    self.onChange(of: toLocalState, by: ==, perform: additionalEffects)
  }
}
