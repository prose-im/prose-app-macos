//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import IdentifiedCollections
import SearchSuggestionsFeature
import SwiftUI

struct Suggestion: Identifiable {
  let jid: String
  let name: String

  var id: String { self.jid }
}

struct ContentView: View {
  private static let allSuggestions: [Suggestion] = [
    .init(jid: "remi@prose.org", name: "Rémi Bardon"),
    .init(jid: "imer@prose.org", name: "The other Rémi Bardon"),
    .init(jid: "marc@prose.org", name: "Marc Bauer"),
    .init(jid: "cram@prose.org", name: "The other Marc Bauer"),
    .init(jid: "valerian@prose.org", name: "Valerian Saliou"),
    .init(jid: "nairelav@prose.org", name: "The other Valerian Saliou"),
  ]

  private var suggestions: IdentifiedArrayOf<Suggestion> {
    IdentifiedArray(uniqueElements: Self.suggestions(for: self.text))
  }

  @State private var text: String = ""
  @State private var selection: Suggestion.ID?

  var body: some View {
    VStack(alignment: .leading) {
      Text("Search for a user 👇")
        .font(.headline)
      Text("You should see a popup appear, and be able to navigate with arrow keys.")
        .font(.subheadline)
      SearchSuggestionsField(text: self.$text, handleKeyboardEvent: self.handleKeyboardEvent) {
        SuggestionsVStack(suggestions: self.suggestions, selection: self.$selection)
      }
      SearchSuggestionsField(text: self.$text, handleKeyboardEvent: self.handleKeyboardEvent) {
        SuggestionsList(suggestions: self.suggestions, selection: self.$selection)
      }
    }
    .fixedSize(horizontal: false, vertical: true)
    .frame(minWidth: 320)
    .padding()
  }

  private static func suggestions(for searchString: String) -> [Suggestion] {
    if searchString.isEmpty { return [] }
    let results = Self.allSuggestions.filter { suggestion in
      let string = suggestion.jid
      let options: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
      guard let range = string.range(of: searchString, options: options) else { return false }
      return !range.isEmpty
    }
    return results
  }

  func handleKeyboardEvent(event: SearchSuggestionEvent) -> SearchSuggestionEventResult {
    switch event {
    case .moveDown:
      return self.moveDown()
    case .moveUp:
      return self.moveUp()
    case .confirmSelection:
      return self.confirmSelection()
    }
  }

  func moveUp() -> SearchSuggestionEventResult {
    guard let selection: Suggestion.ID = self.selection else { return .notHandled }
    guard let index: Int = self.suggestions.index(id: selection) else { return .notHandled }
    let newIndex: Int = max(index - 1, 0)
    self.selection = self.suggestions[newIndex].id
    return .handled
  }

  func moveDown() -> SearchSuggestionEventResult {
    if let index: Int = self.selection.flatMap(self.suggestions.index(id:)) {
      let newIndex: Int = min(index + 1, self.suggestions.count - 1)
      self.selection = self.suggestions[newIndex].id
    } else {
      self.selection = self.suggestions[0].id
    }
    return .handled
  }

  func confirmSelection() -> SearchSuggestionEventResult {
    guard let selection = self.selection else { return .notHandled }
    guard let index = self.suggestions.index(id: selection) else { return .notHandled }
    self.text = self.suggestions[index].jid
    return .close
  }
}
