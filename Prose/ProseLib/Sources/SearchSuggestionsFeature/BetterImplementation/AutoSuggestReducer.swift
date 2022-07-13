//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AutoSuggestClient
import CombineSchedulers
// import ComposableArchitecture
// import Foundation
// import Toolbox
//
// public extension DispatchQueue.SchedulerTimeType.Stride {
//  static let autoSuggestDebounceDuration: Self = .milliseconds(300)
// }
//
// public struct AutoSuggestState<T: Hashable & Identifiable>: Equatable {
////  /// Our token for cancelling effects. We need a one token per instance of auto-suggest reducer
////  /// otherwise [Effect.throttle](x-source-tag://Effect.throttle) won't work as expected, because
////  /// of its side-effecty behavior. While not a problem in practice it would still break our tests.
////  fileprivate var debounceToken = Toolbox.Current.uuid()
////  fileprivate var loadSuggestionsToken = Toolbox.Current.uuid()
//
////  /// - Note: `internal` for testing, could be `fileprivate` otherwise.
////  internal var isFirstSearchQuery = true
//
//  public var noResultText: String
//
//  var content: Loadable<[AutoSuggestSection<T>]>
//
//  public init(noResultText: String) {
//    self.noResultText = noResultText
//  }
// }
//
// public struct AutoSuggestState<T: Hashable>: Equatable {
//
//  public var sections = [AutoSuggestSection<T>]()
//  public var loadingState: LoadingState?
//  var searchQuery: String?
//
//  /// Trim search query on both sides.
//  public var trimmedQuery: String? {
//    let trimmed = self.searchQuery?.trimmingCharacters(in: .whitespacesAndNewlines)
//    return trimmed.flatMap { $0.isEmpty ? nil : $0 }
//  }
// }
//
// public enum AutoSuggestAction<T: Hashable>: Equatable {
//  case onAppear
//  case onDisappear
//
//  case searchQueryChanged(String?)
//  case itemSelected(T)
//  case autoSuggestResponse(Result<[AutoSuggestSection<T>], EquatableError>)
//  case retryButtonTapped
// }

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

// public extension Reducer {
//  /// Enhances a reducer with auto-suggest logic.
//  func autoSuggest<T: Hashable>(
//    state: WritableKeyPath<State, AutoSuggestState<T>>,
//    action: CasePath<Action, AutoSuggestAction<T>>,
//    environment: @escaping (Environment) -> AutoSuggestEnvironment<T>
//  ) -> Reducer {
//    Reducer.combine(
//      self,
//      Reducer<
//        AutoSuggestState<T>,
//        AutoSuggestAction<T>,
//        AutoSuggestEnvironment<T>
//      > { state, action, environment in
//        switch action {
//        case let .searchQueryChanged(query):
//          let query: String? = state.trimmedQuery
//          state.searchQuery = query
//
//          // Only show loading indicator if we don't have any results currently.
//          if state.sections.isEmpty {
//            state.loadingState = .loading
//          }
//
//          let debounceToken = state.debounceToken
//          let isFirstSearchQuery = state.isFirstSearchQuery
//
//          state.isFirstSearchQuery = false
//
//          return Just(query)
//            .setFailureType(to: EquatableError.self)
//            .flatMap { query -> Effect<String?, EquatableError> in
//              // Don't debounce the first query. This removes the initial delay when the
//              // AutoSuggestViewController is presented the first time.
//              if isFirstSearchQuery {
//                return Just(query)
//                  .setFailureType(to: EquatableError.self)
//                  .eraseToEffect()
//              }
//              return Just(query)
//                .setFailureType(to: EquatableError.self)
//                .eraseToEffect()
//                .debounce(
//                  id: debounceToken,
//                  for: .autoSuggestDebounceDuration,
//                  scheduler: environment.mainQueue
//                )
//            }
//            .flatMap { _ -> AnyPublisher<[AutoSuggestSection<T>], EquatableError> in
//              environment.client.loadSuggestions(query)
//                .mapError(EquatableError.init)
//                .eraseToAnyPublisher()
//            }
//            .receive(on: environment.mainQueue)
//            .catchToEffect()
//            .map(AutoSuggestAction.autoSuggestResponse)
//            .cancellable(id: state.loadSuggestionsToken, cancelInFlight: true)
//
//        case .itemSelected:
//          return .none
//
//        case let .autoSuggestResponse(.success(sections)):
//          state.sections = sections.filter { !$0.items.isEmpty }
//          state.loadingState = state.sections.isEmpty
//            ? .empty(message: state.noResultText)
//            : nil
//          return .none
//
//        case let .autoSuggestResponse(.failure(error)):
//          state.sections = []
//          state.loadingState = .error(EquatableError(error))
//          return .none
//
//        case .retryButtonTapped:
//          state.loadingState = .loading
//
//          return environment.client.loadSuggestions(state.trimmedQuery)
//            .mapError(EquatableError.init)
//            .receive(on: environment.mainQueue)
//            .catchToEffect()
//            .map(AutoSuggestAction.autoSuggestResponse)
//            .cancellable(id: state.loadSuggestionsToken, cancelInFlight: true)
//
//        case .onAppear:
//          state.isFirstSearchQuery = true
//          return .none
//
//        case .onDisappear:
//          state.searchQuery = nil
//          state.loadingState = nil
//          state.sections = []
//
//          return .merge(
//            .cancel(id: state.debounceToken),
//            .cancel(id: state.loadSuggestionsToken)
//          )
//        }
//      }
//      .pullback(state: state, action: action, environment: environment)
//    )
//  }
// }
