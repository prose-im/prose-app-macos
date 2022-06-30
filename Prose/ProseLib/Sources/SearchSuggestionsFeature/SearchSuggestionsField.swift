//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AutoSuggestClient
import ComposableArchitecture
import IdentifiedCollections
import SwiftUI

// MARK: - View

public struct SearchSuggestionsField<
  Suggestion: Identifiable & Hashable,
  SuggestionView: View
>: View {
  public typealias ViewState = SearchSuggestionsFieldState<Suggestion>
  public typealias ViewAction = SearchSuggestionsFieldAction<Suggestion>

  let store: Store<ViewState, ViewAction>
  let suggestionView: (Suggestion) -> SuggestionView

  public init(
    store: Store<ViewState, ViewAction>,
    @ViewBuilder suggestionView: @escaping (Suggestion) -> SuggestionView
  ) {
    self.store = store
    self.suggestionView = suggestionView
  }

  public var body: some View {
    WithViewStore(self.store) { viewStore in
      VanillaSearchSuggestionsField(
        text: viewStore.binding(\.$text),
        showSuggestions: viewStore.showSuggestions,
        handleKeyboardEvent: { (event: SearchSuggestionEvent) in
          viewStore.send(.keyboard(event))
          // NOTE: We cannot know if the event was handled here… so let's suppose it was.
          return true
        },
        suggestionsView: {
          VStack(alignment: .leading) {
            ForEach(viewStore.suggestions) { section in
              VStack(alignment: .leading, spacing: 4) {
                Text(section.title)
                  .font(.headline)
                  .foregroundColor(.secondary)
                  .padding(.horizontal, 8)
                  .fixedSize()
                VStack(alignment: .leading, spacing: 0) {
                  ForEach(section.items) { suggestion in
                    self.suggestionView(suggestion)
                      .tag(suggestion.id)
                      .modifier(Selected(suggestion.id == viewStore.selection))
                  }
                }
              }
            }
          }
          .padding(8)
          .frame(maxWidth: .infinity)
        }
      )
      .overlay(alignment: .trailing) {
        if viewStore.isProcessing {
          ProgressView()
            .progressViewStyle(.circular)
            .scaleEffect(0.5)
        }
      }
    }
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

// MARK: - The Composable Architecture

// MARK: Reducer

enum AutoSuggestToken: CaseIterable, Hashable {
  case debounce
  case loadSuggestions
}

public func searchSuggestionsFieldReducer<Suggestion: Identifiable>(
  stringForSuggestion: @escaping (Suggestion) -> String,
  closeWhenConfirmingSelection: Bool = true
) -> Reducer<
  SearchSuggestionsFieldState<Suggestion>,
  SearchSuggestionsFieldAction<Suggestion>,
  AutoSuggestEnvironment<Suggestion>
> {
  Reducer { state, action, environment in
    @discardableResult func handleKeyboardEvent(event: SearchSuggestionEvent) -> Bool {
      switch event {
      case .moveDown:
        return moveDown()
      case .moveUp:
        return moveUp()
      case .confirmSelection:
        return confirmSelection()
      }
    }

    func moveUp() -> Bool {
      guard let selection: Suggestion.ID = state.selection else { return false }
      let suggestions: IdentifiedArrayOf<Suggestion> = IdentifiedArray(
        uniqueElements: state.suggestions.flatMap(\.items)
      )
      guard let index: Int = suggestions.index(id: selection) else { return false }
      let newIndex: Int = max(index - 1, 0)
      state.selection = suggestions[newIndex].id
      return true
    }

    func moveDown() -> Bool {
      let suggestions: IdentifiedArrayOf<Suggestion> = IdentifiedArray(
        uniqueElements: state.suggestions.flatMap(\.items)
      )
      if let index: Int = state.selection.flatMap(suggestions.index(id:)) {
        let newIndex: Int = min(index + 1, suggestions.count - 1)
        state.selection = suggestions[newIndex].id
      } else {
        state.selection = suggestions[0].id
      }
      return true
    }

    func confirmSelection() -> Bool {
      guard let selection = state.selection else { return false }
      let suggestions: IdentifiedArrayOf<Suggestion> = IdentifiedArray(
        uniqueElements: state.suggestions.flatMap(\.items)
      )
      guard let index = suggestions.index(id: selection) else { return false }
      state.text = stringForSuggestion(suggestions[index])
      if closeWhenConfirmingSelection {
        state.showSuggestions = false
      }
      return true
    }

    switch action {
    case let .textDidChange(text):
      state.isProcessing = true
      let excludedTerms: Set<String> = [state.text]
      return environment.client.loadSuggestions(text, excludedTerms)
        .cancellable(id: AutoSuggestToken.loadSuggestions, cancelInFlight: true)
        .replaceError(with: [])
        .eraseToEffect()
        .map(SearchSuggestionsFieldAction.showSuggestions)

    case let .showSuggestions(suggestions):
      state.isProcessing = false
      state.suggestions = IdentifiedArray(uniqueElements: suggestions)
      state.showSuggestions = !suggestions.isEmpty
      print("\(state.suggestions), \(state.showSuggestions)")
      return .none

    case let .keyboard(event):
      handleKeyboardEvent(event: event)
      return .none

    case .binding(\.$text):
      return Effect(value: .textDidChange(state.text))
        .debounce(id: AutoSuggestToken.debounce, for: 0.5, scheduler: environment.mainQueue)
        .eraseToEffect()

    default:
      return .none
    }
  }.binding()
}

// MARK: State

public struct SearchSuggestionsFieldState<Suggestion: Identifiable & Hashable>: Equatable {
  @BindableState var text: String
  var suggestions: IdentifiedArrayOf<AutoSuggestSection<Suggestion>>
  var showSuggestions: Bool
  var selection: Suggestion.ID?
  var isProcessing: Bool

  public init(
    text: String = "",
    suggestions: IdentifiedArrayOf<AutoSuggestSection<Suggestion>> = [],
    showSuggestions: Bool = false,
    selection: Suggestion.ID? = nil,
    isProcessing: Bool = false
  ) {
    self.text = text
    self.suggestions = suggestions
    self.showSuggestions = showSuggestions
    self.selection = selection
    self.isProcessing = isProcessing
  }
}

// MARK: Actions

public enum SearchSuggestionsFieldAction<Suggestion: Identifiable & Hashable>: Equatable,
  BindableAction
{
  case keyboard(SearchSuggestionEvent)
  case textDidChange(String), showSuggestions([AutoSuggestSection<Suggestion>])
  case binding(BindingAction<SearchSuggestionsFieldState<Suggestion>>)
}
