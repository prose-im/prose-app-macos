//
//  AuthenticationView.swift
//  Prose
//
//  Created by Marc Bauer on 01/04/2022.
//

import ComposableArchitecture
import SwiftUI

public struct AuthenticationScreen: View {
    public typealias State = AuthenticationState
    public typealias Action = AuthenticationAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    public init(store: Store<State, Action>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                Section {
                    TextField("Jid", text: viewStore.binding(\.$jid))
                    SecureField("Password", text: viewStore.binding(\.$password))
                }
                Button { actions.send(.loginButtonTapped) } label: {
                    Text("Log into your account")
                }
                .disabled(!viewStore.isFormValid)
            }
            .padding(48)
        }
    }
}

struct AuthenticationScreen_Previews: PreviewProvider {
    private struct Preview: View {
        let state: AuthenticationScreen.State

        var body: some View {
            AuthenticationScreen(store: Store(
                initialState: state,
                reducer: authenticationReducer,
                environment: AuthenticationEnvironment()
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
