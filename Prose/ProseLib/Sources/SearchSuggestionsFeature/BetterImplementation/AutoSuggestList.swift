//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AutoSuggestClient
import ComposableArchitecture
import ProseUI
import SwiftUI
import TcaHelpers

// NOTE: [Rémi Bardon] Those magic numbers come from debugging the view hierarchy of a basic list.
//       The calculations will break if rows/headers do not have the default height.
private let headerHeight: CGFloat = 28
private let rowHeight: CGFloat = 24
private let listSectionVerticalPadding: CGFloat = 20

public struct AutoSuggestList<
  Item: Hashable & Identifiable,
  ItemView: View,
  Placeholder: View
>: View {
  public typealias State = AutoSuggestListState<Item>
  public typealias Action = AutoSuggestListAction<Item>

  let store: Store<State, Action>
  let viewForItem: (Item) -> ItemView
  let placeholder: Placeholder

  public init(
    store: Store<State, Action>,
    @ViewBuilder viewForItem: @escaping (Item) -> ItemView,
    @ViewBuilder placeholder: () -> Placeholder
  ) {
    self.store = store
    self.viewForItem = viewForItem
    self.placeholder = placeholder()
  }

  public var body: some View {
    WithViewStore(self.store) { (viewStore: ViewStore<State, Action>) in
      if let sections = viewStore.state.content.value,
         !sections.filter({ !$0.items.isEmpty }).isEmpty
      {
        List(selection: viewStore.binding(get: \.selection, send: Action.selectionDidChange)) {
          ForEach(sections) { section in
            if !section.items.isEmpty {
              Section(section.title) {
                ForEach(section.items) { item in
                  viewForItem(item)
                    .tag(item.id)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture { viewStore.send(.didSelect(item)) }
                }
              }
            }
          }
        }
        // TODO: We should find a way to avoid those calculations.
        .frame(
          height: CGFloat(sections.reduce(0) { $0 + $1.items.count }) * rowHeight
            + CGFloat(sections.filter { !$0.items.isEmpty }.count) *
            (headerHeight + listSectionVerticalPadding)
        )
      } else {
        self.placeholder
      }
    }
  }
}

// AutoSuggestList(store: self.store.scope(
//  state: \.suggestionList,
//  action: ContactAutoSuggestAction.autoSuggest
// )) { contact in
//  HStack {
//    Text(verbatim: contact.name).bold()
//    Text("—")
//    Text(verbatim: contact.jid)
//  }
// }

@dynamicMemberLookup public struct AutoSuggestListState<T: Hashable & Identifiable>: Equatable {
  public var selection: T.ID?
  public var state: AutoSuggestState<T>

  public init(state: AutoSuggestState<T>) {
    self.state = state
  }

  public subscript<U>(dynamicMember keyPath: WritableKeyPath<AutoSuggestState<T>, U>) -> U {
    get { self.state[keyPath: keyPath] }
    set { self.state[keyPath: keyPath] = newValue }
  }

  @discardableResult mutating func moveUp() -> Bool {
    guard let selection: T.ID = self.selection else { return false }
    guard let sections: [AutoSuggestSection<T>] = self.state.content.value else { return false }
    let items: [T] = sections.flatMap(\.items)
    guard let index: Int = items.firstIndex(where: { $0.id == selection }) else { return false }
    let newIndex: Int = max(index - 1, 0)
    self.selection = items[newIndex].id
    return true
  }

  @discardableResult mutating func moveDown() -> Bool {
    guard let sections: [AutoSuggestSection<T>] = self.state.content.value else { return false }
    let items: [T] = sections.flatMap(\.items)
    if let selection: T.ID = self.selection,
       let index: Int = items.firstIndex(where: { $0.id == selection })
    {
      let newIndex: Int = min(index + 1, items.count - 1)
      self.selection = items[newIndex].id
      return true
    } else if !items.isEmpty {
      self.selection = items[0].id
      return true
    } else {
      return false
    }
  }
}

public enum AutoSuggestListAction<T: Hashable & Identifiable>: Equatable {
  case selectionDidChange(T.ID?)
  case keyboardEventReceived(KeyEvent)
  case didSelect(T)
}

public extension Reducer where Action: Equatable {
  /// Enhances a reducer with auto-suggest logic in a list.
  func autoSuggestList<T: Hashable & Identifiable>(
    state toLocalState: WritableKeyPath<State, AutoSuggestListState<T>>,
    action toLocalAction: CasePath<Action, AutoSuggestListAction<T>>,
    environment toLocalEnvironment: @escaping (Environment) -> AutoSuggestEnvironment<T>,
    autoSuggestAction: @escaping (AutoSuggestAction<T>) -> Action
  ) -> Reducer {
    Reducer.combine([
      self,
      Reducer<
        AutoSuggestListState<T>,
        AutoSuggestListAction<T>,
        AutoSuggestEnvironment<T>
      > { state, action, _ in
        switch action {
        case let .selectionDidChange(id):
          state.selection = id
          return .none

        case let .didSelect(item):
          state.selection = item.id
          return .none

        case .keyboardEventReceived:
          // Handled in the more global reducer
          return .none
        }
      }
      .pullback(state: toLocalState, action: toLocalAction, environment: toLocalEnvironment),
      Reducer<State, Action, Environment> { _, action, _ in
        switch toLocalAction.extract(from: action) {
        case let .didSelect(item):
          return Effect(value: autoSuggestAction(.itemSelected(item)))
        default:
          return .none
        }
      },
    ])
  }

  func autoSuggestListNavigation<T: Hashable & Identifiable>(
    state toLocalState: WritableKeyPath<State, AutoSuggestListState<T>>,
    action toLocalAction: CasePath<Action, AutoSuggestListAction<T>>,
    textViewAction: CasePath<Action, TCATextViewAction>
  ) -> Reducer {
    Reducer.combine([
      self,
      Reducer { state, action, _ in
        switch textViewAction.extract(from: action) {
        case .keyboardEventReceived(.newline):
          guard let id: T.ID = state[keyPath: toLocalState].selection else {
            return .none
          }
          guard let item: T = state[keyPath: toLocalState].state.item(withId: id) else {
            assertionFailure("Selected item could not be found.")
            return .none
          }
          return Effect(value: toLocalAction.embed(.didSelect(item)))

        case .keyboardEventReceived(.down):
          state[keyPath: toLocalState].moveDown()
          return .none

        case .keyboardEventReceived(.up):
          state[keyPath: toLocalState].moveUp()
          return .none

        default:
          return .none
        }
      },
    ])
  }
}

// MARK: - Previews

struct AutoSuggestList_Previews: PreviewProvider {
  struct Preview: View {
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

    let store: Store<State, Action>

    var body: some View {
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
  }

  static var previews: some View {
    Self.preview(AutoSuggestState<Preview.State.Item>(
      content: .loaded([
        .init(
          title: "Section 1",
          items: Array(repeating: Preview.State.Item.init, count: 4).map { $0() }
        ),
        .init(
          title: "Section 2",
          items: Array(repeating: Preview.State.Item.init, count: 1).map { $0() }
        ),
        .init(title: "Section 3", items: []),
        .init(
          title: "Section 4",
          items: Array(repeating: Preview.State.Item.init, count: 3).map { $0() }
        ),
      ])
    ))
  }

  static func preview(_ state: AutoSuggestState<Preview.State.Item>) -> some View {
    Preview(store: Store(
      initialState: Preview.State(
        suggestionList: AutoSuggestListState<Preview.State.Item>(state: state)
      ),
      reducer: Preview.reducer,
      environment: AutoSuggestEnvironment(
        client: .chooseFrom([
          .init(
            title: "Section 1",
            items: Array(repeating: Preview.State.Item.init, count: 4).map { $0() }
          ),
          .init(
            title: "Section 2",
            items: Array(repeating: Preview.State.Item.init, count: 4).map { $0() }
          ),
          .init(
            title: "Section 3",
            items: Array(repeating: Preview.State.Item.init, count: 4).map { $0() }
          ),
        ], on: { [$0.label] }),
        mainQueue: .main
      )
    ))
    .frame(maxWidth: 256)
  }
}
