//
//  AuthenticationScreen.swift
//  Prose
//
//  Created by Marc Bauer on 01/04/2022.
//

import ComposableArchitecture
import SwiftUI
import SwiftUINavigation
import TcaHelpers

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
        WithViewStore(self.store, removeDuplicates: { $0.focusedField == $1.focusedField }) { viewStore in
            VStack(spacing: 32) {
                Spacer()
                Self.header()
                fields()
                logInButton()
                footer()
                Spacer()
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
            Text("Welcome!")
                .font(.system(size: 24, weight: .bold))
            Text("Sign in to your chat account")
                .foregroundColor(.secondary)
                .font(.system(size: 16))
        }
    }

    private func fields() -> some View {
        WithViewStore(self.store, removeDuplicates: { $0.isLoading == $1.isLoading }) { viewStore in
            VStack {
                WithViewStore(self.store, removeDuplicates: { $0.jid == $1.jid }) { viewStore in
                    TextField("Enter your chat address", text: viewStore.binding(\.$jid))
                        .onSubmit { actions.send(.submitTapped(.address)) }
                        .textContentType(.username)
                        .disableAutocorrection(true)
                        .focused($focusedField, equals: .address)
                        .overlay(alignment: .trailing) {
                            chatAddressHelpButton()
                                .alignmentGuide(.trailing) { d in d[.trailing] - 24 }
                        }
                }
                WithViewStore(self.store, removeDuplicates: { $0.password == $1.password }) { viewStore in
                    SecureField("Enter your password…", text: viewStore.binding(\.$password))
                        .onSubmit { actions.send(.submitTapped(.password)) }
                        .textContentType(.password)
                        .disableAutocorrection(true)
                        .focused($focusedField, equals: .password)
                }
            }
            .disabled(viewStore.isLoading)
        }
    }

    private func chatAddressHelpButton() -> some View {
        WithViewStore(
            self.store,
            removeDuplicates: { $0.popover == $1.popover }
        ) { viewStore in
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
    }

    private func logInButton() -> some View {
        WithViewStore(
            self.store,
            removeDuplicates: { $0.isFormValid == $1.isFormValid && $0.isLoading == $1.isLoading }
        ) { viewStore in
            Button {
                actions.send(viewStore.isLoading ? .cancelLogInTapped : .loginButtonTapped)
            } label: {
                Text(viewStore.isLoading ? "Cancel" : "Log into your account")
                    .frame(minWidth: 196)
            }
            .overlay(alignment: .leading) {
                if viewStore.isLoading {
                    ProgressView()
                        .scaleEffect(0.5, anchor: .center)
                }
            }
            .disabled(!viewStore.isFormValid && !viewStore.isLoading)
        }
    }

    private func footer() -> some View {
        HStack(spacing: 16) {
            WithViewStore(
                self.store,
                removeDuplicates: { $0.popover == $1.popover }
            ) { viewStore in
                Button("Lost your password?") { actions.send(.showPopoverTapped(.passwordLost)) }
                    .popover(
                        unwrapping: viewStore.binding(\.$popover),
                        case: /State.Popover.passwordLost,
                        content: { _ in Self.passwordLostPopover() }
                    )
                Divider().frame(height: 18)
                Button("No account yet?") { actions.send(.showPopoverTapped(.noAccount)) }
                    .popover(
                        unwrapping: viewStore.binding(\.$popover),
                        case: /State.Popover.noAccount,
                        content: { _ in Self.noAccountPopover() }
                    )
            }
        }
        .buttonStyle(.link)
    }

    private static func chatAddressPopover() -> some View {
        GroupBox("What is my chat address? (XMPP address)") {
            Text("""
            A chat address is not an email address, but it is very likely
            the same as your professional email address.
            """)
            Text("**It might be:** [your username] @ [your company domain].")
        }
        .groupBoxStyle(PopoverGroupBoxStyle())
    }

    private static func passwordLostPopover() -> some View {
        GroupBox("Lost your password?") {
            // TODO: [Rémi Bardon] Change URL
            Text("""
            Please open this link to our website
            to [recover your password](https://prose.org).
            """)
        }
        .groupBoxStyle(PopoverGroupBoxStyle())
    }

    private static func noAccountPopover() -> some View {
        GroupBox("How do I create a new account? (XMPP address)") {
            // TODO: [Rémi Bardon] Change guide URL
            Text("""
            Chat accounts are hosted on your organization chat server.
            If you are a server administrator, and you are not yet running
            a chat server, please [read this guide](https://prose.org). You will be able to
            invite all your team members afterwards.
            """)
            Text("""
            If you are a team member, ask for an administrator in your
            team to email you an invitation to create your chat account.
            """)
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
        VStack(alignment: .leading, spacing: 8) {
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
