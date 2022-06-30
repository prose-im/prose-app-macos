//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

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
          VStack(alignment: .leading, spacing: 0) {
            ForEach(viewStore.suggestions, id: \.self) { suggestion in
              self.suggestionView(suggestion)
                .tag(suggestion.id)
                .modifier(Selected(suggestion.id == viewStore.selection))
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

private struct Token: Hashable {}
public func searchSuggestionsFieldReducer<Suggestion: Identifiable>(
  suggestions: @escaping (String) async -> IdentifiedArrayOf<Suggestion>,
  stringForSuggestion: @escaping (Suggestion) -> String,
  closeWhenConfirmingSelection: Bool = true
) -> Reducer<
  SearchSuggestionsFieldState<Suggestion>,
  SearchSuggestionsFieldAction<Suggestion>,
  SearchSuggestionsFieldEnvironment
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
      guard let index: Int = state.suggestions.index(id: selection) else { return false }
      let newIndex: Int = max(index - 1, 0)
      state.selection = state.suggestions[newIndex].id
      return true
    }

    func moveDown() -> Bool {
      if let index: Int = state.selection.flatMap(state.suggestions.index(id:)) {
        let newIndex: Int = min(index + 1, state.suggestions.count - 1)
        state.selection = state.suggestions[newIndex].id
      } else {
        state.selection = state.suggestions[0].id
      }
      return true
    }

    func confirmSelection() -> Bool {
      guard let selection = state.selection else { return false }
      guard let index = state.suggestions.index(id: selection) else { return false }
      state.text = stringForSuggestion(state.suggestions[index])
      if closeWhenConfirmingSelection {
        state.showSuggestions = false
      }
      return true
    }

    switch action {
    case let .textDidChange(text):
      state.isProcessing = true
      return Effect.task(priority: .userInitiated) {
        let suggestions = await suggestions(text)
        return .showSuggestions(suggestions)
      }
      .delay(for: 0.5, scheduler: environment.mainQueue)
      .eraseToEffect()

    case let .showSuggestions(suggestions):
      state.isProcessing = false
      state.suggestions = suggestions
      state.showSuggestions = !suggestions.isEmpty
      return .none

    case let .keyboard(event):
      handleKeyboardEvent(event: event)
      return .none

    case .binding(\.$text):
      return Effect(value: .textDidChange(state.text))
        .debounce(id: Token(), for: 0.5, scheduler: environment.mainQueue)
        .eraseToEffect()

    default:
      return .none
    }
  }.binding()
}

// MARK: State

public struct SearchSuggestionsFieldState<Suggestion: Identifiable & Equatable>: Equatable {
  @BindableState var text: String
  var suggestions: IdentifiedArrayOf<Suggestion>
  var showSuggestions: Bool
  var selection: Suggestion.ID?
  var isProcessing: Bool

  public init(
    text: String = "",
    suggestions: IdentifiedArrayOf<Suggestion> = [],
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

public enum SearchSuggestionsFieldAction<Suggestion: Identifiable & Equatable>: Equatable,
  BindableAction
{
  case keyboard(SearchSuggestionEvent)
  case textDidChange(String), showSuggestions(IdentifiedArrayOf<Suggestion>)
  case binding(BindingAction<SearchSuggestionsFieldState<Suggestion>>)
}

// MARK: Environment

public struct SearchSuggestionsFieldEnvironment {
  var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.mainQueue = mainQueue
  }
}

public extension SearchSuggestionsFieldEnvironment {
  static func live(
    mainQueue: AnySchedulerOf<DispatchQueue> = .main
  ) -> SearchSuggestionsFieldEnvironment {
    SearchSuggestionsFieldEnvironment(
      mainQueue: mainQueue
    )
  }
}
