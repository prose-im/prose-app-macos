//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import IdentifiedCollections
import SearchSuggestionsFeature
import SwiftUI

struct SuggestionsVStack: View {
  let suggestions: IdentifiedArrayOf<Suggestion>
  @Binding var selection: Suggestion.ID?

  let select: (Suggestion) -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(self.suggestions) { suggestion in
        Button { self.select(suggestion) } label: {
          Text(verbatim: "\(suggestion.name) – \(suggestion.jid)")
            .tag(suggestion.id)
            .modifier(Selected(suggestion.id == selection))
        }
      }
    }
    .buttonStyle(.plain)
    .listStyle(.inset)
    .padding(8)
    .frame(maxWidth: .infinity)
  }
}

private struct Selected: ViewModifier {
  let isSelected: Bool
  let alignment: Alignment

  init(_ isSelected: Bool, alignment: Alignment = .leading) {
    self.isSelected = isSelected
    self.alignment = alignment
  }

  func body(content: Content) -> some View {
    content
      .fixedSize()
      .frame(maxWidth: .infinity, alignment: self.alignment)
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .foregroundColor(self.isSelected ? Color.white : nil)
      .background {
        if self.isSelected {
          RoundedRectangle(cornerRadius: 4).fill(Color.accentColor.opacity(0.75))
        }
      }
      .accessibilityAddTraits(self.isSelected ? .isSelected : [])
  }
}
