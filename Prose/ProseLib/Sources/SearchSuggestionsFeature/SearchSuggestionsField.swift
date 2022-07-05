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
    NSTextAttachment.registerViewProviderClass(
      MyTextAttachmentViewProvider.self,
      forFileType: MyAttachment.fileType.identifier
    )
    self.store = store
    self.suggestionView = suggestionView
  }

  public var body: some View {
    WithViewStore(self.store) { viewStore in
      WithSuggestionsField(
        store: self.store.scope(state: \ViewState.field, action: ViewAction.field),
        suggestionsView: { suggestionsView(viewStore: viewStore) }
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

  func suggestionsView(viewStore: ViewStore<ViewState, ViewAction>) -> some View {
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
  attachmentForSuggestion: @escaping (Suggestion) -> NSTextAttachment,
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

    @discardableResult func moveUp() -> Bool {
      guard let selection: Suggestion.ID = state.selection else { return false }
      let suggestions: IdentifiedArrayOf<Suggestion> = IdentifiedArray(
        uniqueElements: state.suggestions.flatMap(\.items)
      )
      guard let index: Int = suggestions.index(id: selection) else { return false }
      let newIndex: Int = max(index - 1, 0)
      state.selection = suggestions[newIndex].id
      return true
    }

    @discardableResult func moveDown() -> Bool {
      let suggestions: IdentifiedArrayOf<Suggestion> = IdentifiedArray(
        uniqueElements: state.suggestions.flatMap(\.items)
      )
      if let index: Int = state.selection.flatMap(suggestions.index(id:)) {
        let newIndex: Int = min(index + 1, suggestions.count - 1)
        state.selection = suggestions[newIndex].id
        return true
      } else if !suggestions.isEmpty {
        state.selection = suggestions[0].id
        return true
      } else {
        return false
      }
    }

    @discardableResult func confirmSelection() -> Bool {
      guard let selectionId = state.selection else { return false }
      let suggestions: IdentifiedArrayOf<Suggestion> = IdentifiedArray(
        uniqueElements: state.suggestions.flatMap(\.items)
      )
      guard let suggestion = suggestions[id: selectionId] else { return false }

      let textContentStorage: NSTextContentStorage = state.field.textContentStorage
      guard let attributedString: NSAttributedString = textContentStorage.attributedString else {
        assertionFailure("`textContentStorage.attributedString` should not be `nil`.")
        return false
      }

      // We recalculate the query range here, as the user might have written more characters
      // than when we triggered the suggestions fetching.
      // NOTE: There might be an issue if the user moves the caret, but let's ignore that.
      let queryRange: NSRange = textContentStorage.prose_rangeFromLastAttachmentToCaret()

      let mutableString = NSMutableAttributedString(attributedString: attributedString)
      mutableString.replaceCharacters(in: queryRange, with: NSAttributedString(
        attachment: attachmentForSuggestion(suggestion),
        attributes: vanillaSearchSuggestionsFieldDefaultTextAttributes
      ))
      textContentStorage.attributedString = mutableString

      if closeWhenConfirmingSelection {
        state.field.showSuggestions = false
      }

      return true
    }

    switch action {
    case .fetchSuggestions:
      state.isProcessing = true
      return environment.client.loadSuggestions(state.field.query, state.field.excludedTerms)
        .cancellable(id: AutoSuggestToken.loadSuggestions, cancelInFlight: true)
        .replaceError(with: [])
        .eraseToEffect()
        .map(SearchSuggestionsFieldAction.showSuggestions)

    case let .showSuggestions(suggestions):
      state.isProcessing = false
      state.suggestions = IdentifiedArray(uniqueElements: suggestions)
      state.field.showSuggestions = !suggestions.isEmpty
      return .none

    case let .keyboard(event):
      handleKeyboardEvent(event: event)
      return .none

    case .field(.textDidChange):
      return Effect(value: .fetchSuggestions)
        .debounce(id: AutoSuggestToken.debounce, for: 0.5, scheduler: environment.mainQueue)
        .eraseToEffect()

    case .field(.keyboardEventReceived(.moveUp)):
      moveUp()
      return .none

    case .field(.keyboardEventReceived(.moveDown)):
      moveDown()
      return .none

    case .field(.keyboardEventReceived(.confirmSelection)):
      confirmSelection()
      return .none

    default:
      return .none
    }
  }.binding()
    .combined(with: withSuggestionsFieldReducer.pullback(
      state: \SearchSuggestionsFieldState<Suggestion>.field,
      action: CasePath(SearchSuggestionsFieldAction<Suggestion>.field),
      environment: { _ in () }
    ))
}

// MARK: State

public struct SearchSuggestionsFieldState<Suggestion: Identifiable & Hashable>: Equatable {
  var suggestions: IdentifiedArrayOf<AutoSuggestSection<Suggestion>>
  var selection: Suggestion.ID?
  var isProcessing: Bool

  var field: WithSuggestionsFieldState

  public init(
    field: WithSuggestionsFieldState? = nil,
    suggestions: IdentifiedArrayOf<AutoSuggestSection<Suggestion>> = [],
    selection: Suggestion.ID? = nil,
    isProcessing: Bool = false
  ) {
    self.field = field ?? WithSuggestionsFieldState()
    self.suggestions = suggestions
    self.selection = selection
    self.isProcessing = isProcessing
  }
}

// MARK: Actions

public enum SearchSuggestionsFieldAction<Suggestion: Identifiable & Hashable>: Equatable,
  BindableAction
{
  case keyboard(SearchSuggestionEvent)
  case fetchSuggestions, showSuggestions([AutoSuggestSection<Suggestion>])
  case field(WithSuggestionsFieldAction)
  case binding(BindingAction<SearchSuggestionsFieldState<Suggestion>>)
}
