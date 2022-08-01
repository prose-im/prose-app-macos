//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import Assets
import ComposableArchitecture
import SwiftUI

private let l10n = L10n.Content.MessageBar.self

// MARK: - View

struct MessageBarTextField: View {
  typealias State = MessageBarTextFieldState
  typealias Action = MessageBarTextFieldAction

  @Environment(\.redactionReasons) private var redactionReasons

  @FocusState private var isFocused: Bool

  let store: Store<State, Action>
  private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

  var body: some View {
    WithViewStore(self.store) { viewStore in
      HStack(spacing: 0) {
        TextField(
          l10n.fieldPlaceholder(viewStore.recipient),
          text: viewStore.binding(\State.$message)
        )
        .focused(self.$isFocused)
        .padding(.vertical, 7.0)
        .padding(.leading, 16.0)
        .padding(.trailing, 4.0)
        .font(Font.system(size: 13, weight: .regular))
        .foregroundColor(.primary)
        .textFieldStyle(.plain)
        .onSubmit(of: .text) { actions.send(.sendTapped) }

        Button { actions.send(.sendTapped) } label: {
          Image(systemName: "paperplane.circle.fill")
            .font(.system(size: 22, weight: .regular))
            .foregroundColor(.accentColor)
            .padding(3)
        }
        .buttonStyle(.plain)
        .unredacted()
        .disabled(redactionReasons.contains(.placeholder))
      }
      .background(
        ZStack {
          RoundedRectangle(cornerRadius: 20)
            .fill(.background)
          RoundedRectangle(cornerRadius: 20)
            .strokeBorder(Colors.Border.secondary.color)
        }
      )
      .synchronize(viewStore.binding(\.$isFocused), self.$isFocused)
    }
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let messageBarTextFieldReducer: Reducer<
  MessageBarTextFieldState,
  MessageBarTextFieldAction,
  Void
> = Reducer { state, action, _ in
  switch action {
  case .sendTapped where !state.message.isEmpty:
    let content = state.message
    state.message = ""
    return Effect(value: .send(message: content))

  default:
    return .none
  }
}.binding()

// MARK: State

public struct MessageBarTextFieldState: Equatable {
  var recipient: String
  @BindableState var message: String
  @BindableState var isFocused: Bool = false

  public init(
    recipient: String,
    message: String = ""
  ) {
    self.recipient = recipient
    self.message = message
  }
}

// MARK: Actions

public enum MessageBarTextFieldAction: Equatable, BindableAction {
  case sendTapped
  case send(message: String)
  case binding(BindingAction<MessageBarTextFieldState>)
}

// MARK: - Previews

struct MessageBarTextField_Previews: PreviewProvider {
  private struct Preview: View {
    let state: MessageBarTextFieldState

    var body: some View {
      MessageBarTextField(store: Store(
        initialState: state,
        reducer: messageBarTextFieldReducer,
        environment: ()
      ))
    }
  }

  static var previews: some View {
    Group {
      Preview(state: .init(
        recipient: "Valerian",
        message: "This is a message that was written."
      ))
      .previewDisplayName("Simple message")
      Preview(state: .init(
        recipient: "Valerian",
        message: "This is a \(Array(repeating: "very", count: 20).joined(separator: " ")) long message that was written."
      ))
      .previewDisplayName("Long message")
      Preview(state: .init(
        recipient: "Very \(Array(repeating: "very", count: 20).joined(separator: " ")) long username",
        message: ""
      ))
      .previewDisplayName("Long username")
      Preview(state: .init(
        recipient: "Valerian",
        message: ""
      ))
      .previewDisplayName("Empty")
      Preview(state: .init(
        recipient: "Valerian",
        message: ""
      ))
      .padding()
      .background(Color.pink)
      .previewDisplayName("Colorful background")
    }
    .preferredColorScheme(.light)
    Group {
      Preview(state: .init(
        recipient: "Valerian",
        message: "This is a message that was written."
      ))
      .previewDisplayName("Simple message / Dark")
      Preview(state: .init(
        recipient: "Valerian",
        message: ""
      ))
      .previewDisplayName("Empty / Dark")
      Preview(state: .init(
        recipient: "Valerian",
        message: ""
      ))
      .padding()
      .background(Color.pink)
      .previewDisplayName("Colorful background / Dark")
    }
    .preferredColorScheme(.dark)
  }
}
