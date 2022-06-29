//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import SearchSuggestionsFeature
import SwiftUI

struct ContentView: View {
  private static let allSuggestions: [SuggestionsList.Suggestion] = [
    .init(jid: "remi@prose.org", name: "Rémi Bardon"),
    .init(jid: "imer@prose.org", name: "The other Rémi Bardon"),
    .init(jid: "marc@prose.org", name: "Marc Bauer"),
    .init(jid: "cram@prose.org", name: "The other Marc Bauer"),
    .init(jid: "valerian@prose.org", name: "Valerian Saliou"),
    .init(jid: "nairelav@prose.org", name: "The other Valerian Saliou"),
  ]

  private var suggestions: [SuggestionsList.Suggestion] { Self.suggestions(for: self.text) }

  @State private var text: String = ""
  @State private var selection: SuggestionsList.Suggestion.ID?

  var body: some View {
    VStack(alignment: .leading) {
      Text("Search for a user 👇")
        .font(.headline)
      Text("You should see a popup appear, and be able to navigate with arrow keys.")
        .font(.subheadline)
      SearchSuggestionsField(text: self.$text) {
        SuggestionsList(suggestions: self.suggestions, selection: $selection)
      } moveUp: {
        guard let selection = self.selection else { return false }
        guard let index = self.suggestions.firstIndex(where: { $0.id == selection })
        else { return false }
        let newIndex = max(index - 1, 0)
        self.selection = self.suggestions[newIndex].id
        return true
      } moveDown: {
        guard let selection = self.selection else { return false }
        guard let index = self.suggestions.firstIndex(where: { $0.id == selection })
        else { return false }
        let newIndex = min(index + 1, self.suggestions.count - 1)
        self.selection = self.suggestions[newIndex].id
        return true
      } select: {
        guard let selection = self.selection else { return (false, false) }
        guard let index = self.suggestions.firstIndex(where: { $0.id == selection })
        else { return (false, false) }
        self.text = self.suggestions[index].jid
        return (true, true)
      }
    }
    .fixedSize(horizontal: false, vertical: true)
    .frame(minWidth: 320)
    .padding()
    .onChange(of: self.text) { _ in
      print("suggestions: \(self.suggestions.map(\.jid))")
    }
  }

  private static func suggestions(for searchString: String) -> [SuggestionsList.Suggestion] {
    if searchString.isEmpty { return [] }
    let results = Self.allSuggestions.filter { suggestion in
      let string = suggestion.name
      let options: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
      guard let range = string.range(of: searchString, options: options) else { return false }
      return !range.isEmpty
    }
    return results
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
