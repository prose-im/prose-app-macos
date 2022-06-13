//
//  AuthenticationScreen.swift
//  Prose
//
//  Created by Marc Bauer on 01/04/2022.
//

import AppLocalization
import ComposableArchitecture
import SwiftUI
import SwiftUINavigation
import TcaHelpers

private let l10n = L10n.Authentication.LogIn.self

public struct AuthenticationScreen: View {
    public typealias State = AuthenticationState
    public typealias Action = AuthenticationAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    @FocusState private var focusedField: State.Field?

    public init(store: Store<State, Action>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(spacing: 32) {
                Self.header()
                fields(viewStore: viewStore)
                logInButton(viewStore: viewStore)
                footer(viewStore: viewStore)
            }
            .multilineTextAlignment(.center)
            .controlSize(.large)
            .textFieldStyle(.roundedBorder)
            .buttonBorderShape(.roundedRectangle)
            .padding(.horizontal, 48)
            .padding(.vertical, 24)
            .synchronize(viewStore.binding(\.$focusedField), self.$focusedField)
            .alert(self.store.scope(state: \.alert), dismiss: .alertDismissed)
        }
    }

    private static func header() -> some View {
        VStack(spacing: 4) {
            Text("👋")
                .font(.system(size: 64))
                .padding(.bottom, 20)
            Text(l10n.Header.title)
                .font(.system(size: 24, weight: .bold))
            Text(l10n.Header.subtitle)
                .foregroundColor(.secondary)
                .font(.system(size: 16))
        }
    }

    private func fields(viewStore: ViewStore<State, Action>) -> some View {
        VStack {
            TextField(l10n.Form.ChatAddress.placeholder, text: viewStore.binding(\.$jid))
                .onSubmit { actions.send(.submitTapped(.address)) }
                .textContentType(.username)
                .disableAutocorrection(true)
                .focused($focusedField, equals: .address)
                .overlay(alignment: .trailing) {
                    chatAddressHelpButton(viewStore: viewStore)
                        .alignmentGuide(.trailing) { d in d[.trailing] - 24 }
                }
            SecureField(l10n.Form.Password.placeholder, text: viewStore.binding(\.$password))
                .onSubmit { actions.send(.submitTapped(.password)) }
                .textContentType(.password)
                .disableAutocorrection(true)
                .focused($focusedField, equals: .password)
        }
        .disabled(viewStore.isLoading)
    }

    private func chatAddressHelpButton(viewStore: ViewStore<State, Action>) -> some View {
        Button { actions.send(.showPopoverTapped(.chatAddress)) } label: {
            Image(systemName: "questionmark")
        }
        .buttonStyle(CircleButtonStyle())
        .popover(
            unwrapping: viewStore.binding(\.$popover),
            case: /State.Popover.chatAddress,
            content: { _ in Self.chatAddressPopover() }
        )
    }

    private func logInButton(viewStore: ViewStore<State, Action>) -> some View {
        Button {
            actions.send(viewStore.isLoading ? .cancelLogInTapped : .loginButtonTapped)
        } label: {
            Text(viewStore.isLoading ? l10n.Cancel.Action.title : l10n.LogIn.Action.title)
                .frame(minWidth: 196)
        }
        .overlay(alignment: .leading) {
            if viewStore.isLoading {
                ProgressView()
                    .scaleEffect(0.5, anchor: .center)
            }
        }
        .disabled(!viewStore.isActionButtonEnabled)
    }

    private func footer(viewStore: ViewStore<State, Action>) -> some View {
        HStack(spacing: 16) {
            Button(l10n.PasswordLost.Action.title) { actions.send(.showPopoverTapped(.passwordLost)) }
                .popover(
                    unwrapping: viewStore.binding(\.$popover),
                    case: /State.Popover.passwordLost,
                    content: { _ in Self.passwordLostPopover() }
                )
            Divider().frame(height: 18)
            Button(l10n.NoAccount.Action.title) { actions.send(.showPopoverTapped(.noAccount)) }
                .popover(
                    unwrapping: viewStore.binding(\.$popover),
                    case: /State.Popover.noAccount,
                    content: { _ in Self.noAccountPopover() }
                )
        }
        .buttonStyle(.link)
    }

    private static func chatAddressPopover() -> some View {
        GroupBox(l10n.ChatAddress.Popover.title) {
            Text(l10n.ChatAddress.Popover.content.asMarkdown)
        }
        .groupBoxStyle(PopoverGroupBoxStyle())
    }

    private static func passwordLostPopover() -> some View {
        GroupBox(l10n.PasswordLost.Popover.title) {
            Text(l10n.PasswordLost.Popover.content.asMarkdown)
        }
        .groupBoxStyle(PopoverGroupBoxStyle())
    }

    private static func noAccountPopover() -> some View {
        GroupBox(l10n.NoAccount.Popover.title) {
            Text(l10n.NoAccount.Popover.content.asMarkdown)
        }
        .groupBoxStyle(PopoverGroupBoxStyle())
    }
}

private struct CircleButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .frame(width: 20, height: 20)
            .contentShape(Circle())
            .background {
                Circle()
                    .fill(Color(nsColor: .controlColor))
                    .shadow(color: Color.black.opacity(0.25), radius: 0, y: 0.5)
            }
            .overlay {
                Circle()
                    .strokeBorder(Color.black.opacity(0.15), lineWidth: 0.5)
            }
            .opacity((configuration.isPressed || !self.isEnabled) ? 0.5 : 1)
    }
}

private struct PopoverGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            configuration.label
                .font(.headline)
            configuration.content
        }
        .font(.body)
        .scaledToFit()
        .multilineTextAlignment(.leading)
        .padding(16)
    }
}

struct AuthenticationScreen_Previews: PreviewProvider {
    private struct Preview: View {
        let state: AuthenticationScreen.State

        var body: some View {
            AuthenticationScreen(store: Store(
                initialState: state,
                reducer: authenticationReducer,
                environment: AuthenticationEnvironment(
                    mainQueue: .main
                )
            ))
        }
    }

    static var previews: some View {
        Preview(state: .init())
            .previewLayout(.sizeThatFits)
        Preview(state: .init(jid: "remi@prose.org", password: "password"))
            .previewLayout(.sizeThatFits)
        Preview(state: .init(jid: "remi@prose.org", password: "password"))
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
