//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import SwiftUI

struct SuggestionsList: View {
  struct Suggestion: Identifiable {
    let jid: String
    let name: String

    var id: String { self.jid }
  }

  let suggestions: [Suggestion]
  @Binding var selection: Suggestion.ID?

  var body: some View {
    if !self.suggestions.isEmpty {
      List(selection: self.$selection) {
        ForEach(self.suggestions) { suggestion in
          Text(verbatim: "\(suggestion.name) – \(suggestion.jid)")
            .tag(suggestion.id)
        }
      }
      .buttonStyle(.plain)
      .fixedSize(horizontal: false, vertical: true)
    }
  }
}

struct SuggestionsList_Previews: PreviewProvider {
  static var previews: some View {
    SuggestionsList(suggestions: [
      .init(jid: "remi@prose.org", name: "Rémi Bardon"),
    ], selection: .constant(nil))
  }
}
