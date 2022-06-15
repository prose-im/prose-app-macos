//
//  MFAView.swift
//  Prose
//
//  Created by Rémi Bardon on 13/06/2022.
//

import ComposableArchitecture
import SwiftUI

// MARK: - View

struct MFAView: View {
    typealias State = MFAState
    typealias Action = MFAAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    var body: some View {
        SwitchStore(self.store) {
            CaseLet(state: /State.sixDigits, action: Action.sixDigits, then: MFA6DigitsView.init(store:))
        }
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let mfaReducer: Reducer<
    MFAState,
    MFAAction,
    AuthenticationEnvironment
> = Reducer.combine([
    mfa6DigitsReducer.pullback(
        state: /MFAState.sixDigits,
        action: /MFAAction.sixDigits,
        environment: { $0 }
    ),
    Reducer { _, action, _ in
        switch action {
        case let .sixDigits(.verifyOneTimeCodeResult(.success(route))):
            return Effect(value: .didPassChallenge(next: route))

        default:
            break
        }

        return .none
    },
])

// MARK: State

public enum MFAState: Equatable {
    case sixDigits(MFA6DigitsState)
}

// MARK: Actions

public enum MFAAction: Equatable {
    case didPassChallenge(next: AuthRoute)
    case sixDigits(MFA6DigitsAction)
}
