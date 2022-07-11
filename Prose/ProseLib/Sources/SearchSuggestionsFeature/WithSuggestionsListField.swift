//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AutoSuggestClient
import ComposableArchitecture
import IdentifiedCollections
import SwiftUI

// MARK: - View

public struct WithSuggestionsListField<
  Suggestion: Identifiable & Hashable,
  SuggestionView: View
>: View {
  public typealias ViewState = WithSuggestionsListFieldState<Suggestion>
  public typealias ViewAction = WithSuggestionsListFieldAction<Suggestion>

  let store: Store<ViewState, ViewAction>
  let suggestionView: (Suggestion) -> SuggestionView

  public init(
    store: Store<ViewState, ViewAction>,
    @ViewBuilder suggestionView: @escaping (Suggestion) -> SuggestionView
  ) {
    // TODO: [Rémi Bardon] I saw some way to attach a view provider on a `NSTextElement` or something
    //       in TextKit 2. We should use this method instead, as currently we could have conflicts
    //       on `JIDAttachment.fileType.identifier` (not a custom identifier).
    NSTextAttachment.registerViewProviderClass(
      MyTextAttachmentViewProvider.self,
      forFileType: JIDAttachment.fileType.identifier
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

/// The reducer for ``WithSuggestionsListField``.
/// - Parameters:
///   - attachmentForSuggestion: A function to transform a `Suggestion` to a ``NSTextAttachment``.
///     It's not in the ``WithSuggestionsListFieldState``, as it would break the ``Equatable`` conformance.
///   - stringFromAttachment: A function to transform a ``NSTextAttachment`` into a ``String``.
///     This ``String`` value is used to create the list of terms excluded from the suggestions fetch request.
///     Note that this function can return `nil` if the ``NSTextAttachment`` was not of the correct type.
///   - closeWhenConfirmingSelection: A boolean indicating if we should close the companion window when
///     the user confirms their selection. It's not in the state, as this information depends on the view
///     placement on screen (and in the hierarchy), and not the view state itself.
///     For example, in a field used to enter a single JID, it shouldn't be possible to change the state
///     to `closeWhenConfirmingSelection = false`. This is therefore enforced by the reducer.
public func searchSuggestionsFieldReducer<Suggestion: Identifiable>(
  attachmentForSuggestion: @escaping (Suggestion) -> NSTextAttachment,
  stringFromAttachment: @escaping (NSTextAttachment) -> String?,
  closeWhenConfirmingSelection: Bool = true
) -> Reducer<
  WithSuggestionsListFieldState<Suggestion>,
  WithSuggestionsListFieldAction<Suggestion>,
  AutoSuggestEnvironment<Suggestion>
> {
  Reducer { state, action, environment in
    switch action {
    case .fetchSuggestions:
      state.isProcessing = true

      let excludedTerms: Set<String> = state.field
        .excludedTerms(stringFromAttachment: stringFromAttachment)
      return environment.client.loadSuggestions(state.field.query, excludedTerms)
        .cancellable(id: AutoSuggestToken.loadSuggestions, cancelInFlight: true)
        .replaceError(with: [])
        .eraseToEffect()
        .map(WithSuggestionsListFieldAction.showSuggestions)

    case let .showSuggestions(suggestions):
      state.isProcessing = false
      state.suggestions = IdentifiedArray(uniqueElements: suggestions)
      state.field.showSuggestions = !suggestions.isEmpty
      return .none

    case .field(.textDidChange):
      return Effect(value: .fetchSuggestions)
        .debounce(id: AutoSuggestToken.debounce, for: 0.5, scheduler: environment.mainQueue)
        .eraseToEffect()

    case .field(.keyboardEventReceived(.moveUp)):
      state.moveUp()
      return .none

    case .field(.keyboardEventReceived(.moveDown)):
      state.moveDown()
      return .none

    case .field(.keyboardEventReceived(.confirmSelection)):
      state.confirmSelection(attachmentForSuggestion: attachmentForSuggestion)

      if closeWhenConfirmingSelection {
        state.field.showSuggestions = false
      }

      return .none

    default:
      return .none
    }
  }
  .binding()
  .combined(with: withSuggestionsFieldReducer.pullback(
    state: \WithSuggestionsListFieldState<Suggestion>.field,
    action: CasePath(WithSuggestionsListFieldAction<Suggestion>.field),
    environment: { _ in () }
  ))
}

// MARK: State

public struct WithSuggestionsListFieldState<Suggestion: Identifiable & Hashable>: Equatable {
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
    self.suggestions = suggestions
    self.selection = selection
    self.isProcessing = isProcessing
    self.field = field ?? WithSuggestionsFieldState()
  }

  /// - Returns: A boolean indicating if the event was handled. Historically comes from the AppKit
  ///   `textView(_:doCommandBy:) -> Bool` function, even though we haven't found a way to use
  ///   the return value yet (hence the `@discardableResult`).
  @discardableResult mutating func moveUp() -> Bool {
    guard let selection: Suggestion.ID = self.selection else { return false }
    let suggestions: IdentifiedArrayOf<Suggestion> = IdentifiedArray(
      uniqueElements: self.suggestions.flatMap(\.items)
    )
    guard let index: Int = suggestions.index(id: selection) else { return false }
    let newIndex: Int = max(index - 1, 0)
    self.selection = suggestions[newIndex].id
    return true
  }

  /// - Returns: A boolean indicating if the event was handled. Historically comes from the AppKit
  ///   `textView(_:doCommandBy:) -> Bool` function, even though we haven't found a way to use
  ///   the return value yet (hence the `@discardableResult`).
  @discardableResult mutating func moveDown() -> Bool {
    let suggestions: IdentifiedArrayOf<Suggestion> = IdentifiedArray(
      uniqueElements: self.suggestions.flatMap(\.items)
    )
    if let index: Int = self.selection.flatMap(suggestions.index(id:)) {
      let newIndex: Int = min(index + 1, suggestions.count - 1)
      self.selection = suggestions[newIndex].id
      return true
    } else if !suggestions.isEmpty {
      self.selection = suggestions[0].id
      return true
    } else {
      return false
    }
  }

  /// - Returns: A boolean indicating if the event was handled. Historically comes from the AppKit
  ///   `textView(_:doCommandBy:) -> Bool` function, even though we haven't found a way to use
  ///   the return value yet (hence the `@discardableResult`).
  @discardableResult mutating func confirmSelection(
    attachmentForSuggestion: (Suggestion) -> NSTextAttachment
  ) -> Bool {
    guard let selectionId = self.selection else { return false }
    let suggestions: IdentifiedArrayOf<Suggestion> = IdentifiedArray(
      uniqueElements: self.suggestions.flatMap(\.items)
    )
    guard let suggestion = suggestions[id: selectionId] else { return false }

    let textContentStorage: NSTextContentStorage = self.field.textContentStorage
    guard let attributedString: NSAttributedString = textContentStorage.attributedString else {
      assertionFailure("`textContentStorage.attributedString` should not be `nil`.")
      return false
    }

    // We recalculate the query range here, as the user might have written more characters
    // than when we triggered the suggestions fetching.
    // NOTE: There might be an issue if the user moves the caret, but let's ignore that.
    let queryRange: NSRange = textContentStorage.prose_rangeFromLastAttachmentToCaret()

    let replacement = NSAttributedString(
      attachment: attachmentForSuggestion(suggestion),
      attributes: defaultTextAttributes
    ).appendingSpace()

    let mutableString = NSMutableAttributedString(attributedString: attributedString)
    mutableString.replaceCharacters(in: queryRange, with: replacement)

    textContentStorage.performEditingTransaction {
      // Change the text
      assert(textContentStorage.textStorage != nil)
      textContentStorage.textStorage?.setAttributedString(mutableString)

      // Update selection
      let textLayoutManager = textContentStorage.textLayoutManagers.first
      assert(textLayoutManager != nil)
      let newSelection: NSTextLocation = textLayoutManager?.location(
        textContentStorage.documentRange.location,
        offsetBy: replacement.length
      ) ?? textContentStorage.documentRange.endLocation
      #warning(
        "FIXME: `textLayoutManager?.textSelections = […]` doesn't move the caret, which leaves the view in a inconsistent state."
      )
      textLayoutManager?.textSelections = [
        NSTextSelection(newSelection, affinity: .upstream),
      ]
    }

    return true
  }
}

// MARK: Actions

public enum WithSuggestionsListFieldAction<Suggestion: Identifiable & Hashable>: Equatable,
  BindableAction
{
  case fetchSuggestions, showSuggestions([AutoSuggestSection<Suggestion>])
  case field(WithSuggestionsFieldAction)
  case binding(BindingAction<WithSuggestionsListFieldState<Suggestion>>)
}
