//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import ProseCoreTCA
import SwiftUI
import SwiftUINavigation

public struct ReactionPickerState: Equatable {
  let reactions: [Reaction] = "👋👉👍😂😢😭😍😘😊🤯❤️🙏😛🚀⚠️😀😌😇🙃🙂🤩🥳🤨🙁😳🤔😐👀✅❌"
    .map { Reaction(rawValue: String($0)) }
  var selected: Set<Reaction>

  let columnCount: Int = 5
  let fontSize: CGFloat = 24
  let spacing: CGFloat = 4

  var width: CGFloat { self.fontSize * 1.5 }
  var height: CGFloat { self.width }

  public init(selected: Set<Reaction> = []) {
    self.selected = selected
  }
}

public enum ReactionPickerAction: Equatable {
  case select(Reaction), deselect(Reaction)
}

public let reactionPickerTogglingReducer = AnyReducer<
  ReactionPickerState,
  ReactionPickerAction,
  Void
> { state, action, _ in
  switch action {
  case let .select(reaction):
    state.selected.insert(reaction)
    return .none
  case let .deselect(reaction):
    state.selected.remove(reaction)
    return .none
  }
}

public struct ReactionPicker: View {
  let store: Store<ReactionPickerState, ReactionPickerAction>

  public init(store: Store<ReactionPickerState, ReactionPickerAction>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(self.store) { viewStore in
      LazyVGrid(columns: Self.columns(state: viewStore.state), spacing: viewStore.spacing) {
        ForEach(viewStore.reactions, id: \.self) { reaction in
          let isSelected: Bool = viewStore.selected.contains(reaction)
          Button {
            viewStore.send(isSelected ? .deselect(reaction) : .select(reaction))
          } label: {
            Text(reaction.rawValue)
              .font(.system(size: viewStore.fontSize))
              .frame(width: viewStore.width, height: viewStore.height)
              .modifier(Selected(viewStore.selected.contains(reaction)))
              .fixedSize()
          }
          .buttonStyle(.plain)
          .contentShape(Rectangle())
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

private struct Selected: ViewModifier {
  let isSelected: Bool

  init(_ isSelected: Bool) {
    self.isSelected = isSelected
  }

  func body(content: Content) -> some View {
    content
      .compositingGroup()
      .background {
        if self.isSelected {
          RoundedRectangle(cornerRadius: 8)
            .strokeBorder(.selection, lineWidth: 2)
            // Make sure the border looks good on material backgrounds
            // (otherwise not enough contrast)
            .blendMode(.plusDarker)
        }
      }
      .accessibilityAddTraits(self.isSelected ? .isSelected : [])
  }
}

public extension View {
  func reactionPicker<Action>(
    store: Store<ReactionPickerState?, Action>,
    action: @escaping (ReactionPickerAction) -> Action,
    dismiss: Action
  ) -> some View {
    WithViewStore(store) { viewStore in
      self.popover(unwrapping: viewStore.binding(send: dismiss)) { $state in
        ReactionPicker(store: store.scope(
          state: { _ in $state.wrappedValue },
          action: action
        ))
      }
    }
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

    static let reducer = AnyReducer<State, Action, Void>.combine([
      reactionPickerTogglingReducer.optional().pullback(
        state: \.reactionPicker,
        action: CasePath(Action.reactionPicker),
        environment: { $0 }
      ),
      AnyReducer { state, action, _ in
        switch action {
        case let .reactionPicker(.select(reaction)):
          state.text = reaction.rawValue
          return .none
        case .reactionPicker(.deselect):
          state.text = ""
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
      @BindingState var isShowingPopover: Bool = false
    }

    enum Action: Equatable, BindableAction {
      case reactionPicker(ReactionPickerAction)
      case binding(BindingAction<State>)
    }

    static let reducer = AnyReducer<State, Action, Void>.combine([
      //      reactionPickerTogglingReducer.optional().pullback(
//        state: \.reactionPicker,
//        action: CasePath(Action.reactionPicker),
//        environment: { $0 }
//      ),
      AnyReducer { state, action, _ in
        switch action {
        case let .reactionPicker(.select(reaction)):
          state.text = reaction.rawValue
          state.isShowingPopover = false
          return .none
        case .reactionPicker(.deselect):
          state.text = ""
          return .none
        case .binding:
          return .none
        }
      }.binding(),
    ])

    let store: Store<State, Action> = Store(
      initialState: State(reactionPicker: ReactionPickerState()),
      reducer: Self.reducer,
      environment: ()
    )

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
    Preview1(initialState: .init(selected: ["🥳", "❤️", "🤩"]))
    Preview2()
  }
}
