//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import ProseCoreTCA
import SwiftUI

public struct ReactionPickerState: Equatable {
  let reactions: [Reaction] = "👋👉👍😂😢😭😍😘😊🤯❤️🙏😛🚀⚠️😀😌😇🙃🙂🤩🥳🤨🙁😳🤔😐👀✅❌"
    .map { Reaction(rawValue: String($0)) }
  var selected = Set<Reaction>()

  let columnCount: Int = 5
  let fontSize: CGFloat = 24
  let spacing: CGFloat = 4

  var width: CGFloat { self.fontSize * 1.5 }
  var height: CGFloat { self.width }
}

public enum ReactionPickerAction: Equatable {
  case select(Reaction)
}

public let reactionPickerReducer = Reducer<
  ReactionPickerState,
  ReactionPickerAction,
  Void
> { state, action, _ in
  switch action {
  case let .select(reaction):
    state.selected.insert(reaction)
    return .none
  }
}

struct ReactionPicker: View {
  let store: Store<ReactionPickerState, ReactionPickerAction>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      LazyVGrid(columns: Self.columns(state: viewStore.state), spacing: viewStore.spacing) {
        ForEach(viewStore.reactions, id: \.self) { reaction in
          Button { viewStore.send(.select(reaction)) } label: {
            Text(reaction.rawValue)
              .font(.system(size: viewStore.fontSize))
              .frame(width: viewStore.width, height: viewStore.height)
              .overlay {
                if viewStore.selected.contains(reaction) {
                  RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.selection, lineWidth: 2)
                }
              }
              .fixedSize()
          }
          .buttonStyle(.plain)
        }
      }
      .padding(viewStore.spacing * 2)
    }
  }

  static func gridItem(state: ReactionPickerState) -> GridItem {
    GridItem(.fixed(state.width), spacing: state.spacing)
  }
  static func columns(state: ReactionPickerState) -> [GridItem] {
    Array(repeating: Self.gridItem(state: state), count: state.columnCount)
  }
}

struct ReactionPicker_Previews: PreviewProvider {
  private struct Preview1: View {
    struct State: Equatable {
      var reactionPicker: ReactionPickerState?
      var text: String = ""
    }
    enum Action: Equatable {
      case reactionPicker(ReactionPickerAction)
    }

    static let reducer = Reducer<State, Action, Void>.combine([
      reactionPickerReducer.optional().pullback(
        state: \.reactionPicker,
        action: CasePath(Action.reactionPicker),
        environment: { $0 }
      ),
      Reducer { state, action, _ in
        switch action {
        case let .reactionPicker(.select(reaction)):
          state.text = reaction.rawValue
          return .none
        }
      },
    ])

    let store: Store<State, Action>

    init(initialState: ReactionPickerState) {
      self.store = Store(
        initialState: State(reactionPicker: initialState),
        reducer: Self.reducer,
        environment: ()
      )
    }

    var body: some View {
      VStack(alignment: .leading) {
        WithViewStore(self.store.scope(state: \.text)) { viewStore in
          Text("Reaction: '\(viewStore.state)'")
            .padding([.horizontal, .top])
        }
        IfLetStore(
          self.store.scope(state: \.reactionPicker, action: Action.reactionPicker),
          then: ReactionPicker.init(store:)
        )
      }
      .fixedSize()
      .previewDisplayName("As a view")
    }
  }
  private struct Preview2: View {
    struct State: Equatable {
      var reactionPicker: ReactionPickerState?
      var text: String = ""
      @BindableState var isShowingPopover: Bool = false
    }
    enum Action: Equatable, BindableAction {
      case reactionPicker(ReactionPickerAction)
      case binding(BindingAction<State>)
    }

    static let reducer = Reducer<State, Action, Void>.combine([
      reactionPickerReducer.optional().pullback(
        state: \.reactionPicker,
        action: CasePath(Action.reactionPicker),
        environment: { $0 }
      ),
      Reducer { state, action, _ in
        switch action {
        case let .reactionPicker(.select(reaction)):
          state.text = reaction.rawValue
          state.isShowingPopover = false
          return .none
        case .binding:
          return .none
        }
      }.binding(),
    ])

    let store: Store<State, Action>

    init(initialState: ReactionPickerState) {
      self.store = Store(
        initialState: State(reactionPicker: initialState),
        reducer: Self.reducer,
        environment: ()
      )
    }

    var body: some View {
      HStack {
        WithViewStore(self.store.scope(state: \.text)) { viewStore in
          Text("Reaction: '\(viewStore.state)'")
            .frame(width: 128, alignment: .leading)
        }
        WithViewStore(self.store) { viewStore in
          Toggle("Show?", isOn: viewStore.binding(\.$isShowingPopover))
            .popover(isPresented: viewStore.binding(\.$isShowingPopover)) {
              IfLetStore(
                self.store.scope(state: \.reactionPicker, action: Action.reactionPicker),
                then: ReactionPicker.init(store:)
              )
            }
        }
      }
      .padding()
      .fixedSize()
      .previewDisplayName("As a popover")
    }
  }

  static var previews: some View {
    Preview1(initialState: .init(selected: ["🥳"]))
    Preview2(initialState: .init(selected: ["❤️", "🤩"]))
  }
}
