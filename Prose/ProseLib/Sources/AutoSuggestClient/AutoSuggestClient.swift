//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Combine
import ComposableArchitecture
import Foundation

public typealias SuggestionLoader<T: Hashable> = (
  _ searchQuery: String,
  _ excludedTerms: Set<String>
) -> Effect<[AutoSuggestSection<T>], Error>

public struct AutoSuggestClient<T: Hashable> {
  public var loadSuggestions: SuggestionLoader<T>

  public init(loadSuggestions: @escaping SuggestionLoader<T>) {
    self.loadSuggestions = loadSuggestions
  }
}

public struct AutoSuggestSection<T: Hashable> {
  public var title: String
  public var items: [T]

  public init(title: String, items: [T]) {
    self.title = title
    self.items = items
  }
}

extension AutoSuggestSection: Identifiable {
  public var id: String { self.title }
}

extension AutoSuggestSection: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.title < rhs.title
  }
}
