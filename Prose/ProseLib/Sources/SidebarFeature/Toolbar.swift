//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import SwiftUI

private let l10n = L10n.Sidebar.Toolbar.self

// MARK: - View

struct Toolbar: ToolbarContent {
  typealias State = ToolbarState
  typealias Action = ToolbarAction

  @Environment(\.redactionReasons) private var redactionReasons

  let store: Store<State, Action>
  private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

  var body: some ToolbarContent {
    ToolbarItemGroup(placement: ToolbarItemPlacement.primaryAction) {
      Self.actions(store: store, redactionReasons: self.redactionReasons)
    }
  }

  static func actions(
    store: Store<State, Action>,
    redactionReasons: RedactionReasons
  ) -> some View {
    WithViewStore(store) { viewStore in
      Button { viewStore.send(.startCallTapped) } label: {
        Label(l10n.Actions.StartCall.label, systemImage: "phone.bubble.left")
      }
      .unredacted()
      .accessibilityHint(l10n.Actions.StartCall.hint)
      Toggle(isOn: viewStore.binding(\State.$writingNewMessage)) {
        Label(l10n.Actions.WriteMessage.label, systemImage: "square.and.pencil")
      }
      .toggleStyle(.button)
      .unredacted()
      .accessibilityHint(l10n.Actions.WriteMessage.hint)
    }
    .disabled(redactionReasons.contains(.placeholder))
    // https://github.com/prose-im/prose-app-macos/issues/45
    .disabled(true)
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

let toolbarReducer: Reducer<
  ToolbarState,
  ToolbarAction,
  Void
> = Reducer { state, action, _ in
  switch action {
  case .startCallTapped:
    // TODO: [Rémi Bardon] Handle action
    logger.info("Start call tapped")

  case .binding(\.$writingNewMessage):
    // TODO: [Rémi Bardon] Handle action
    if state.writingNewMessage {
      logger.info("Start writing new message tapped")
    } else {
      logger.info("Stop writing new message tapped")
    }

  case .binding:
    break
  }

  return .none
}.binding()

// MARK: State

public struct ToolbarState: Equatable {
  @BindableState var writingNewMessage = false
}

// MARK: Actions

public enum ToolbarAction: Equatable, BindableAction {
  case startCallTapped
  case binding(BindingAction<ToolbarState>)
}

// MARK: - Previews

internal struct Toolbar_Previews: PreviewProvider {
  private struct Preview: View {
    @Environment(\.redactionReasons) private var redactionReasons

    let state: ToolbarState

    var body: some View {
      let store = Store(
        initialState: state,
        reducer: toolbarReducer,
        environment: ()
      )
      HStack {
        Toolbar.actions(
          store: store,
          redactionReasons: redactionReasons
        )
      }
      .padding()
      .previewLayout(.sizeThatFits)
    }
  }

  static var previews: some View {
    Preview(state: .init())
    Preview(state: .init())
      .redacted(reason: .placeholder)
      .previewDisplayName("Placeholder")
  }
}
