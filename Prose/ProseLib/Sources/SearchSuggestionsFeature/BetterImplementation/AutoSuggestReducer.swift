//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AutoSuggestClient
import Combine
import CombineSchedulers
import ComposableArchitecture
import Toolbox

public extension DispatchQueue.SchedulerTimeType.Stride {
  static let autoSuggestDebounceDuration: Self = .milliseconds(300)
}

struct UniqueCancellationToken: Hashable {
  let uuid: UUID
  static func uuid() -> Self { Self(uuid: UUID()) }
}

public struct AutoSuggestState<T: Hashable & Identifiable>: Equatable {
  /// Our token for cancelling effects. We need a one token per instance of auto-suggest reducer
  /// otherwise [Effect.throttle](x-source-tag://Effect.throttle) won't work as expected, because
  /// of its side-effecty behavior. While not a problem in practice it would still break our tests.
  fileprivate var debounceToken = UniqueCancellationToken.uuid()
  fileprivate var loadSuggestionsToken = UniqueCancellationToken.uuid()

  /// - Note: `internal` for testing, could be `fileprivate` otherwise.
  internal var isFirstSearchQuery = true

  var searchQuery: String?

  public var content: Loadable<[AutoSuggestSection<T>]>

  /// Trim search query on both sides.
  public var trimmedQuery: String? {
    let trimmed = self.searchQuery?.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.flatMap { $0.isEmpty ? nil : $0 }
  }

  public init(
    content: Loadable<[AutoSuggestSection<T>]> = .notRequested
  ) {
    self.content = content
  }

  /// - Warning: This implementation is not very efficient, but as we only have a few results,
  ///            let's ignore the issue.
  public func item(withId id: T.ID) -> T? {
    self.content.value?
      .compactMap { section in
        section.items.first(where: { $0.id == id })
      }
      .first
  }
}

public enum AutoSuggestAction<T: Hashable & Identifiable>: Equatable {
  case onAppear
  case onDisappear

  case searchQueryChanged(String?)
  case itemSelected(T)
  case autoSuggestResponse(Result<[AutoSuggestSection<T>], EquatableError>)
  case retryButtonTapped
}

public struct AutoSuggestEnvironment<T: Hashable> {
  /// The client performing search queries.
  var client: AutoSuggestClient<T>

  /// A reference to the main queue.
  var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(client: AutoSuggestClient<T>, mainQueue: AnySchedulerOf<DispatchQueue>) {
    self.client = client
    self.mainQueue = mainQueue
  }
}

public extension Reducer {
  /// Enhances a reducer with auto-suggest logic.
  func autoSuggest<T: Hashable>(
    state: WritableKeyPath<State, AutoSuggestState<T>>,
    action: CasePath<Action, AutoSuggestAction<T>>,
    environment: @escaping (Environment) -> AutoSuggestEnvironment<T>
  ) -> Reducer {
    Reducer.combine(
      self,
      Reducer<
        AutoSuggestState<T>,
        AutoSuggestAction<T>,
        AutoSuggestEnvironment<T>
      > { state, action, environment in
        switch action {
        case let .searchQueryChanged(query):
          state.searchQuery = query

          guard let query: String = state.trimmedQuery else {
            // There is nothing to do if the query is empty (e.g. just spaces)
            return .none
          }

          // Only show loading indicator if we don't have any results currently.
          if state.content.value == nil {
            state.content.transitionToLoading()
          }

          let debounceToken = state.debounceToken
          let isFirstSearchQuery = state.isFirstSearchQuery

          state.isFirstSearchQuery = false

          func debounceIfNeeded(_ query: String) -> Effect<String, EquatableError> {
            // Don't debounce the first query. This removes the initial delay when the
            // `AutoSuggestViewController` is presented the first time.
            if isFirstSearchQuery {
              return Just(query)
                .setFailureType(to: EquatableError.self)
                .eraseToEffect()
            }
            return Just(query)
              .setFailureType(to: EquatableError.self)
              .eraseToEffect()
              .debounce(
                id: debounceToken,
                for: .autoSuggestDebounceDuration,
                scheduler: environment.mainQueue
              )
          }

          func executeQuery(_ query: String)
            -> AnyPublisher<[AutoSuggestSection<T>], EquatableError>
          {
            environment.client.loadSuggestions(query, Set())
              .mapError(EquatableError.init)
              .eraseToAnyPublisher()
          }

          return Just(query)
            .setFailureType(to: EquatableError.self)
            .flatMap(debounceIfNeeded)
            .flatMap(executeQuery)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(AutoSuggestAction.autoSuggestResponse)
            .cancellable(id: state.loadSuggestionsToken, cancelInFlight: true)

        case .itemSelected:
          return .none

        case let .autoSuggestResponse(.success(sections)):
          let sections: [AutoSuggestSection<T>] = sections.filter { !$0.items.isEmpty }
          state.content = .loaded(sections)
          return .none

        case let .autoSuggestResponse(.failure(error)):
          state.content.transitionToError(EquatableError(error))
          return .none

        case .retryButtonTapped:
          guard let query = state.trimmedQuery else {
            // There is nothing to do if the query is empty (e.g. just spaces)
            return .none
          }

          state.content.transitionToLoading()

          return environment.client.loadSuggestions(query, Set())
            .mapError(EquatableError.init)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(AutoSuggestAction.autoSuggestResponse)
            .cancellable(id: state.loadSuggestionsToken, cancelInFlight: true)

        case .onAppear:
          state.isFirstSearchQuery = true
          return .none

        case .onDisappear:
          state.searchQuery = nil
          state.content = .notRequested

          return Effect.merge(
            Effect.cancel(id: state.debounceToken),
            Effect.cancel(id: state.loadSuggestionsToken)
          )
        }
      }
      .pullback(state: state, action: action, environment: environment)
    )
  }
}
