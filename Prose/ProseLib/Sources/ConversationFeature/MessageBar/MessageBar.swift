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

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 16) {
                leadingButtons()

                ZStack {
                    WithViewStore(self.store) { viewStore in
                        MessageBarTextField(
                            firstName: viewStore.firstName,
                            message: viewStore.binding(\State.$message)
                        )

                        TypingIndicator(
                            firstName: viewStore.firstName
                        )
                        .offset(y: -Self.height / 2)
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

    @ViewBuilder
    private func leadingButtons() -> some View {
        HStack(spacing: 12) {
            Button(action: {}) {
                Image(systemName: "textformat.alt")
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func trailingButtons() -> some View {
        HStack(spacing: 12) {
            Button(action: {}) {
                Image(systemName: "paperclip")
            }
            Button(action: {}) {
                Image(systemName: "face.smiling")
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let messageBarReducer: Reducer<
    MessageBarState,
    MessageBarAction,
    Void
> = Reducer.empty.binding()
// Reducer { state, action, environment in
//    switch action {
//    }
//
//    return .none
// }

// MARK: State

public struct MessageBarState: Equatable {
    let firstName: String
    @BindableState var message: String

    public init(
        firstName: String,
        message: String = ""
    ) {
        self.firstName = firstName
        self.message = message
    }
}

// MARK: Actions

public enum MessageBarAction: Equatable, BindableAction {
    case binding(BindingAction<MessageBarState>)
}

// MARK: - Previews

internal struct MessageBar_Previews: PreviewProvider {
    private struct Preview: View {
        let firstName: String

        var body: some View {
            MessageBar(store: Store(
                initialState: MessageBarState(firstName: firstName),
                reducer: messageBarReducer,
                environment: ()
            ))
        }
    }

    static var previews: some View {
        Group {
            Preview(
                firstName: "Valerian"
            )
            .previewDisplayName("Simple username")
            Preview(
                firstName: "Very \(Array(repeating: "very", count: 20).joined(separator: " ")) long username"
            )
            .previewDisplayName("Long username")
            Preview(
                firstName: ""
            )
            .previewDisplayName("Empty")
            Preview(
                firstName: "Valerian"
            )
            .padding()
            .background(Color.pink)
            .previewDisplayName("Colorful background")
        }
        .preferredColorScheme(.light)
        Group {
            Preview(
                firstName: "Valerian"
            )
            .previewDisplayName("Simple username / Dark")
            Preview(
                firstName: ""
            )
            .previewDisplayName("Empty / Dark")
            Preview(
                firstName: "Valerian"
            )
            .padding()
            .background(Color.pink)
            .previewDisplayName("Colorful background / Dark")
        }
        .preferredColorScheme(.dark)
    }
}
