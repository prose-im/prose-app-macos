//
//  MessageBar.swift
//  Prose
//
//  Created by Valerian Saliou on 11/21/21.
//

import ComposableArchitecture
import SwiftUI

// MARK: - View

struct MessageBar: View {
    typealias State = MessageBarState
    typealias Action = MessageBarAction

    static let height: CGFloat = 64

    @Environment(\.redactionReasons) private var redactionReasons

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 16) {
                leadingButtons()

                ZStack {
                    MessageBarTextField(store: self.store.scope(
                        state: \State.textField,
                        action: Action.textField
                    ))

                    WithViewStore(self.store) { viewStore in
                        if !viewStore.typing.isEmpty {
                            TypingIndicator(typing: viewStore.typing)
                                .offset(y: -Self.height / 2)
                        }
                    }
                }

                trailingButtons()
            }
            .font(.title2)
            .padding(.horizontal, 20)
            .frame(maxHeight: Self.height)
        }
        .frame(height: Self.height)
        .foregroundColor(.secondary)
        // TODO: [Rémi Bardon] Maybe add a material background here, to make it more beautiful with content going under
//        .background(.ultraThinMaterial)
        .background(.background)
        // Make sure accessibility frame is correct
        .contentShape(Rectangle())
        .accessibilityElement(children: .contain)
    }

    private func leadingButtons() -> some View {
        HStack(spacing: 12) {
            Button { actions.send(.textFormatTapped) } label: {
                Image(systemName: "textformat.alt")
            }
        }
        .buttonStyle(.plain)
        .unredacted()
        .disabled(self.redactionReasons.contains(.placeholder))
    }

    private func trailingButtons() -> some View {
        HStack(spacing: 12) {
            Button { actions.send(.addAttachmentTapped) } label: {
                Image(systemName: "paperclip")
            }
            Button { actions.send(.showEmojisTapped) } label: {
                Image(systemName: "face.smiling")
            }
        }
        .buttonStyle(.plain)
        .unredacted()
        .disabled(self.redactionReasons.contains(.placeholder))
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let messageBarReducer: Reducer<
    MessageBarState,
    MessageBarAction,
    Void
> = Reducer.combine([
    messageBarTextFieldReducer.pullback(
        state: \MessageBarState.textField,
        action: CasePath(MessageBarAction.textField),
        environment: { $0 }
    ),
    Reducer.empty.binding(),
])

// MARK: State

public struct MessageBarState: Equatable {
    var textField: MessageBarTextFieldState
    var typing: [String]

    public init(
        textField: MessageBarTextFieldState,
        typing: [String] = []
    ) {
        self.textField = textField
        self.typing = typing
    }
}

// MARK: Actions

public enum MessageBarAction: Equatable, BindableAction {
    case textFormatTapped, addAttachmentTapped, showEmojisTapped
    case textField(MessageBarTextFieldAction)
    case binding(BindingAction<MessageBarState>)
}

// MARK: - Previews

internal struct MessageBar_Previews: PreviewProvider {
    private struct Preview: View {
        let recipient: String

        var body: some View {
            MessageBar(store: Store(
                initialState: MessageBarState(
                    textField: .init(recipient: recipient),
                    typing: [recipient]
                ),
                reducer: messageBarReducer,
                environment: ()
            ))
        }
    }

    static var previews: some View {
        Group {
            Preview(
                recipient: "Valerian"
            )
            .previewDisplayName("Simple username")
            Preview(
                recipient: "Very \(Array(repeating: "very", count: 20).joined(separator: " ")) long username"
            )
            .previewDisplayName("Long username")
            Preview(
                recipient: ""
            )
            .previewDisplayName("Empty")
            Preview(
                recipient: "Valerian"
            )
            .padding()
            .background(Color.pink)
            .previewDisplayName("Colorful background")
            Preview(
                recipient: "Valerian"
            )
            .redacted(reason: .placeholder)
            .previewDisplayName("Placeholder")
        }
        .preferredColorScheme(.light)
        Group {
            Preview(
                recipient: "Valerian"
            )
            .previewDisplayName("Simple username / Dark")
            Preview(
                recipient: ""
            )
            .previewDisplayName("Empty / Dark")
            Preview(
                recipient: "Valerian"
            )
            .padding()
            .background(Color.pink)
            .previewDisplayName("Colorful background / Dark")
            Preview(
                recipient: "Valerian"
            )
            .redacted(reason: .placeholder)
            .previewDisplayName("Placeholder / Dark")
        }
        .preferredColorScheme(.dark)
    }
}
