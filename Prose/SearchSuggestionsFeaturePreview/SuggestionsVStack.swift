//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import IdentifiedCollections
import SearchSuggestionsFeature
import SwiftUI

struct SuggestionsVStack: View {
  static let rowHeight: CGFloat = 24
  static let stackVerticalPadding: CGFloat = 16

  let suggestions: IdentifiedArrayOf<Suggestion>
  @Binding var selection: Suggestion.ID?

  let select: (Suggestion) -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(self.suggestions) { suggestion in
        Button { self.select(suggestion) } label: {
          Text(verbatim: "\(suggestion.name) – \(suggestion.jid)")
            .tag(suggestion.id)
            .frame(maxWidth: .infinity, alignment: .leading)
            .modifier(Selected(suggestion.id == selection))
        }
      }
    }
    .buttonStyle(.plain)
    .listStyle(.inset)
    .padding(8)
    .frame(height: CGFloat(self.suggestions.count) * Self.rowHeight + Self.stackVerticalPadding)
    .frame(maxWidth: .infinity)
  }
}

struct Selected: ViewModifier {
  let isSelected: Bool

  init(_ isSelected: Bool) {
    self.isSelected = isSelected
  }

  func body(content: Content) -> some View {
    content
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .foregroundColor(self.isSelected ? Color.white : nil)
      .background {
        if self.isSelected {
          RoundedRectangle(cornerRadius: 4).fill(Color.accentColor)
        }
      }
  }
}
