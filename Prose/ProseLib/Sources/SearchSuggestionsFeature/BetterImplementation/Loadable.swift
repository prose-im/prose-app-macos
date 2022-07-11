//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import Toolbox

/// Represents the different states of a loadable item.
public enum Loadable<Value: Equatable>: Equatable {
  /// Item has not yet been loaded.
  case notRequested
  /// Item is in the process of loading and any previously loaded state.
  case loading(previous: Value?)
  /// Item has successfully loaded.
  case loaded(Value)
  /// Item failed to load.
  case error(EquatableError, previous: Value?)
}

public extension Loadable {
  /// The current value of the item, if it has been previously loaded.
  var value: Value? {
    switch self {
    case let .loaded(value):
      return value
    case let .loading(previous):
      return previous
    case let .error(_, previous):
      return previous
    default:
      return nil
    }
  }

  var error: EquatableError? {
    if case let .error(error, _) = self {
      return error
    }
    return nil
  }

  var isLoadedOrLoading: Bool {
    switch self {
    case .loading, .loaded:
      return true
    case .notRequested, .error:
      return false
    }
  }

  var isLoading: Bool {
    switch self {
    case .loading:
      return true
    case .loaded, .notRequested, .error:
      return false
    }
  }

  var isLoaded: Bool {
    switch self {
    case .loaded:
      return true
    case .notRequested, .loading, .error:
      return false
    }
  }
}

public extension Loadable {
  /// Returns a ``Loadable`` containing the results of mapping the given closure over the receiver.
  func map<T>(_ transform: (Value?) -> T) -> Loadable<T> {
    switch self {
    case .notRequested:
      return .notRequested
    case let .loading(previous):
      return .loading(previous: transform(previous))
    case let .loaded(value):
      return .loaded(transform(value))
    case let .error(error, previous):
      return .error(error, previous: transform(previous))
    }
  }

  func mapValue<T>(_ transform: (Value) -> T) -> Loadable<T> {
    switch self {
    case .notRequested:
      return .notRequested
    case let .loading(.some(previous)):
      return .loading(previous: transform(previous))
    case .loading(.none):
      return .loading(previous: nil)
    case let .loaded(value):
      return .loaded(transform(value))
    case let .error(error, .some(previous)):
      return .error(error, previous: transform(previous))
    case let .error(error, .none):
      return .error(error, previous: nil)
    }
  }

  mutating func mapInPlace(_ transform: (inout Value) throws -> Void) rethrows {
    switch self {
    case .notRequested:
      return
    case var .loaded(entity):
      try transform(&entity)
      self = .loaded(entity)
    case var .loading(previous: .some(entity)):
      try transform(&entity)
      self = .loading(previous: entity)
    case .loading(.none):
      return
    case .error(let error, previous: .some(var entity)):
      try transform(&entity)
      self = .error(error, previous: entity)
    case .error(_, .none):
      return
    }
  }

  mutating func transitionToLoading() {
    switch self {
    case .notRequested:
      self = .loading(previous: nil)
    case let .loading(previous):
      self = .loading(previous: previous)
    case let .loaded(value):
      self = .loading(previous: value)
    case let .error(_, previous):
      self = .loading(previous: previous)
    }
  }

  mutating func transitionToError(_ error: EquatableError) {
    switch self {
    case .notRequested:
      self = .error(error, previous: nil)
    case let .loading(previous):
      self = .error(error, previous: previous)
    case let .loaded(value):
      self = .error(error, previous: value)
    case let .error(_, previous):
      self = .error(error, previous: previous)
    }
  }
}

// public extension Loadable where Value: Collection {
//  func loadingState(emptyMessage: String?) -> LoadingState? {
//    switch self {
//    case .notRequested:
//      return .loading
//    case .loading(previous: .none):
//      return .loading
//    case let .loading(previous: .some(value)) where value.isEmpty:
//      return emptyMessage.map(LoadingState.empty)
//    case .loading(.some):
//      return nil
//    case let .loaded(value) where value.isEmpty:
//      return emptyMessage.map(LoadingState.empty)
//    case .loaded:
//      return nil
//    case let .error(.some(value), _) where !value.isEmpty:
//      return nil
//    case let .error(_, error):
//      return .error(error)
//    }
//  }
// }
//
// public extension Loadable {
//  var loadingState: LoadingState? {
//    switch self {
//    case .notRequested, .loading(.none):
//      return .loading
//    case .loading(.some), .loaded, .error(.some, _):
//      return nil
//    case let .error(.none, error):
//      return .error(error)
//    }
//  }
// }
