//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AutoSuggestClient
import ComposableArchitecture
import SearchSuggestionsFeature
import SwiftUI

struct AutoSuggestListPreview: View {
  struct State: Equatable {
    struct Item: Hashable, Identifiable {
      let id = UUID()
      var label: String { String(self.id.uuidString.prefix(8)) }
    }

    var suggestionList: AutoSuggestListState<Item>
    var selected: [Item] = []
  }

  enum Action: Equatable {
    case autoSuggest(AutoSuggestAction<State.Item>)
    case autoSuggestList(AutoSuggestListAction<State.Item>)
  }

  static let reducer = Reducer<State, Action, AutoSuggestEnvironment<State.Item>>
    .empty
    .autoSuggestList(
      state: \.suggestionList,
      action: CasePath(Action.autoSuggestList),
      environment: { $0 },
      autoSuggestAction: Action.autoSuggest
    )
    .combined(with: Reducer { state, action, _ in
      switch action {
      case let .autoSuggest(.itemSelected(item)):
        state.selected.append(item)
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

      case .autoSuggest, .autoSuggestList:
        return .none
      }
    })

  let store: Store<State, Action>

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
      WithViewStore(self.store.scope(state: \.selected)) { viewStore in
        VStack {
          ForEach(viewStore.state) { item in
            Text(item.label)
          }
        }
      }
      AutoSuggestList(store: self.store.scope(
        state: \.suggestionList,
        action: Action.autoSuggestList
      )) { item in
        Text(item.label)
      } placeholder: {
        Text("No result yet")
          .italic()
          .foregroundColor(.secondary)
          .frame(maxWidth: .infinity)
          .padding()
      }
    }
    .padding()
    .frame(maxWidth: 256)
  }
}
