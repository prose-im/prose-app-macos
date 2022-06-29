//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import IdentifiedCollections
import SearchSuggestionsFeature
import SwiftUI

struct SuggestionsList: View, SuggestionsViewProtocol {
  static let rowHeight: CGFloat = 24
  static let listVerticalPadding: CGFloat = 20

  let suggestions: IdentifiedArrayOf<Suggestion>
  @Binding var selection: Suggestion.ID?

  var shouldBeVisible: Bool { !self.suggestions.isEmpty }

  var body: some View {
      List(selection: self.$selection) {
        ForEach(self.suggestions) { suggestion in
          Text(verbatim: "\(suggestion.name) – \(suggestion.jid)")
            .tag(suggestion.id)
        }
      }
      .buttonStyle(.plain)
      .listStyle(.inset)
      .frame(height: CGFloat(self.suggestions.count) * Self.rowHeight + Self.listVerticalPadding)
  }
}
