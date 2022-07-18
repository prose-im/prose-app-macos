//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import IdentifiedCollections
import SearchSuggestionsFeature
import SwiftUI

struct Suggestion: Identifiable, Hashable {
  let jid: String
  let name: String

  var id: String { self.jid }
}

struct NaivePreview: View {
  private static let allSuggestions: [Suggestion] = [
    .init(jid: "remi@prose.org", name: "Rémi Bardon"),
    .init(jid: "imer@prose.org", name: "The other Rémi Bardon"),
    .init(jid: "marc@prose.org", name: "Marc Bauer"),
    .init(jid: "cram@prose.org", name: "The other Marc Bauer"),
    .init(jid: "valerian@prose.org", name: "Valerian Saliou"),
    .init(jid: "nairelav@prose.org", name: "The other Valerian Saliou"),
  ]

  private var suggestions: IdentifiedArrayOf<Suggestion> {
    IdentifiedArray(uniqueElements: Self.suggestions(for: self.text.description))
  }

  @State private var text = AttributedString()
  @State private var selection: Suggestion.ID?

  private let tcaStore = Store(
    initialState: WithSuggestionsListFieldState(),
    reducer: searchSuggestionsFieldReducer(
      attachmentForSuggestion: { JIDAttachment(jid: $0.jid, displayName: $0.name) },
      stringFromAttachment: { (attachment: NSTextAttachment) -> String? in
        guard let jid = (attachment as? JIDAttachment)?.jid else {
          assertionFailure("`attachment` is not a `JIDAttachment`")
          return nil
        }
        return jid
      }
    ),
    environment: .init(
      client: .chooseFrom([
        .init(title: "In your team", items: Self.allSuggestions),
      ], on: { [$0.jid, $0.name] }),
      mainQueue: .main
    )
  )
  #warning("Add back the vanilla logic")
  private let simpleStore = Store(
    initialState: WithSuggestionsFieldState(),
    reducer: withSuggestionsFieldReducer,
    environment: ()
  )

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      VStack(alignment: .leading) {
        Text("Search for a user 👇")
          .font(.headline)
        Text("You should see a popup appear, and be able to navigate with arrow keys.")
          .font(.subheadline)
      }
      VStack(alignment: .leading, spacing: 4) {
        Text("TCA, `VStack` content")
        WithSuggestionsListField(store: self.tcaStore) { suggestion in
          Text(verbatim: "\(suggestion.name) – \(suggestion.jid)")
        }
      }
      VStack(alignment: .leading, spacing: 4) {
        Text("Vanilla SwiftUI, `VStack` content")
        WithSuggestionsField(store: self.simpleStore) {
          SuggestionsVStack(
            suggestions: self.suggestions,
            selection: self.$selection,
            select: { self.text = AttributedString($0.jid) }
          )
        }
      }
      VStack(alignment: .leading, spacing: 4) {
        Text("Vanilla SwiftUI, `List` content")
        WithSuggestionsField(store: self.simpleStore) {
          SuggestionsList(
            suggestions: self.suggestions,
            selection: self.$selection,
            select: { self.text = AttributedString($0.jid) }
          )
        }
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
        && !(range.lowerBound == string.startIndex && range.upperBound == string.endIndex)
    }
    return results
  }

  func handleKeyboardEvent(event: SearchSuggestionEvent) -> Bool {
    switch event {
    case .moveDown:
      return self.moveDown()
    case .moveUp:
      return self.moveUp()
    case .confirmSelection:
      return self.confirmSelection()
    }
  }

  func moveUp() -> Bool {
    guard let selection: Suggestion.ID = self.selection else { return false }
    guard let index: Int = self.suggestions.index(id: selection) else { return false }
    let newIndex: Int = max(index - 1, 0)
    self.selection = self.suggestions[newIndex].id
    return true
  }

  func moveDown() -> Bool {
    if let index: Int = self.selection.flatMap(self.suggestions.index(id:)) {
      let newIndex: Int = min(index + 1, self.suggestions.count - 1)
      self.selection = self.suggestions[newIndex].id
      return true
    } else if !self.suggestions.isEmpty {
      self.selection = self.suggestions[0].id
      return true
    } else {
      return false
    }
  }

  func confirmSelection() -> Bool {
    guard let selection = self.selection else { return false }
    guard let index = self.suggestions.index(id: selection) else { return false }
    self.text = AttributedString(self.suggestions[index].jid)
    return true
  }
}
