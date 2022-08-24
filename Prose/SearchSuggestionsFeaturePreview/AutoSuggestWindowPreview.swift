//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AutoSuggestClient
import ComposableArchitecture
import ProseUI
import SearchSuggestionsFeature
import SwiftUI

struct AutoSuggestWindowPreview: View {
  struct State: Equatable {
    struct Item: Hashable, Identifiable {
      let id = UUID()
      var label: String { String(self.id.uuidString.prefix(8)) }
    }

    var suggestionList: AutoSuggestListState<Item>
    var selected: [Item] = []

    var textView = TCATextViewState()

    var text: String { ListFormatter.localizedString(byJoining: self.selected.map(\.label)) }
  }

  enum Action: Equatable {
    case textView(TCATextViewAction)
    case autoSuggest(AutoSuggestAction<State.Item>)
    case autoSuggestList(AutoSuggestListAction<State.Item>)
  }

  static let reducer = Reducer<State, Action, AutoSuggestEnvironment<State.Item>>.combine([
    textViewReducer.pullback(
      state: \State.textView,
      action: CasePath(Action.textView),
      environment: { _ in () }
    ),
    Reducer.empty
      .autoSuggestList(
        state: \.suggestionList,
        action: CasePath(Action.autoSuggestList),
        environment: { $0 },
        autoSuggestAction: Action.autoSuggest
      )
      .autoSuggestListNavigation(
        state: \.suggestionList,
        action: CasePath(Action.autoSuggestList),
        textViewAction: CasePath(Action.textView)
      ),
    Reducer { state, action, _ in
      switch action {
      case let .autoSuggest(.itemSelected(item)):
        state.selected.append(item)
        state.textView.text = AttributedString(state.text)

        state.suggestionList.selection = nil
        let itemId: State.Item.ID = item.id
        state.suggestionList.content = state.suggestionList.content.map { value in
          guard let value = value else { return [] }
          return value.map { (section: AutoSuggestSection<State.Item>) in
            var section = section
            section.items.removeAll(where: { $0.id == itemId })
            return section
          }
        }
        return .none

      case .textView, .autoSuggest, .autoSuggestList:
        return .none
      }
    },
  ])

  let store: Store<State, Action>

  @SwiftUI.State private var showWindow: Bool = true

  init(_ state: AutoSuggestState<State.Item>) {
    self.store = Store(
      initialState: State(
        suggestionList: AutoSuggestListState<State.Item>(state: state)
      ),
      reducer: Self.reducer,
      environment: AutoSuggestEnvironment(
        client: .chooseFrom([
          .init(
            title: "Section 1",
            items: Array(repeating: State.Item.init, count: 4).map { $0() }
          ),
          .init(
            title: "Section 2",
            items: Array(repeating: State.Item.init, count: 4).map { $0() }
          ),
          .init(
            title: "Section 3",
            items: Array(repeating: State.Item.init, count: 4).map { $0() }
          ),
        ], on: { [$0.label] }),
        mainQueue: .main
      )
    )
  }

  var body: some View {
    VStack {
      Toggle("Show window?", isOn: self.$showWindow)
//      WithViewStore(self.store.scope(state: \.selected)) { viewStore in
//        TextField(
//          "Preview",
//          text: .constant(ListFormatter.localizedString(byJoining: viewStore.state.map(\.label)))
//        )
//        // NOTE: Does not work
//        .onKeyDown(.newline) { viewStore.send(.autoSuggestList(.newlineTapped)) }
//      }
      TCATextView(store: self.store.scope(state: \.textView, action: Action.textView))
        .attachedWindow(isPresented: self.showWindow) {
          AutoSuggestList(store: self.store.scope(
            state: \.suggestionList,
            action: Action.autoSuggestList
          )) { item in
            Text(item.label)
              .fixedSize()
          } placeholder: {
            Text("No result yet")
              .italic()
              .foregroundColor(.secondary)
              .frame(maxWidth: .infinity)
              .padding()
          }
          .environment(\.controlActiveState, .active)
        }
    }
    .padding()
    .frame(maxWidth: 256, maxHeight: 256, alignment: .top)
  }

  static func items(_ count: Int) -> [State.Item] {
    Array(repeating: AutoSuggestWindowPreview.State.Item.init, count: count).map { $0() }
  }
}
