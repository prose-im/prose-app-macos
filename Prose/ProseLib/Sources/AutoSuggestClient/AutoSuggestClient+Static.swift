//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import Foundation

public extension AutoSuggestClient {
  static func chooseFrom(
    _ suggestions: [AutoSuggestSection<T>],
    on searchFields: @escaping (T) -> Set<String>,
    delay: DispatchQueue.SchedulerTimeType.Stride = 0.125,
    mainQueue: AnySchedulerOf<DispatchQueue> = .main
  ) -> AutoSuggestClient<T> {
    AutoSuggestClient(
      loadSuggestions: { searchQuery, excluded in
        if searchQuery.isEmpty { return Effect(value: []) }

        let filteredSuggestions: [AutoSuggestSection<T>] = suggestions.compactMap { section in
          let filteredItems: [T] = section.items.filter { suggestion -> Bool in
            let fields: Set<String> = searchFields(suggestion)

            // Make sure no term is excluded (e.g. already in search field token)
            guard fields.intersection(excluded).isEmpty else { return false }

            // Search for a match in the fields (e.g. search in the JID and the full name)
            return fields.contains { string -> Bool in
              // NOTE: "The search is locale-aware, case and diacritic insensitive."
              string.localizedStandardContains(searchQuery)
            }
          }

          return filteredItems.isEmpty ? nil : AutoSuggestSection(
            title: section.title,
            items: filteredItems
          )
        }

        return Effect(value: filteredSuggestions)
          // A small delay pretend there was a network call
          .delay(for: delay, scheduler: mainQueue)
          .eraseToEffect()
      }
    )
  }
}
