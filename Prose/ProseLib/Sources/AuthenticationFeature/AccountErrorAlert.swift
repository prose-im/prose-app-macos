//
//  AccountErrorAlert.swift
//  Prose
//
//  Created by Rémi Bardon on 24/06/2022.
//

import AppLocalization
import ComposableArchitecture
import SwiftUI

private let l10n = L10n.Authentication.AccountErrorAlert.self

// MARK: View

public extension View {
    func accountErrorAlert<Action>(
        _ store: Store<AlertState<AccountErrorAlertAction>?, Action>
    ) -> some View
        where Action: WithAccountErrorAction & Equatable
    {
        self
            .alert(store.scope(state: { $0 }, action: Action.accountErrorAlert), dismiss: .dismiss)
    }
}

// MARK: - The Composabe Architecture

// MARK: Reducer

private let accountErrorAlertReducer = Reducer<
    AlertState<AccountErrorAlertAction>,
    AccountErrorAlertAction,
    Void
> { _, action, _ in
    switch action {
    default:
        logger.trace("Account error popup unhandled action: \(String(describing: action))")
        return .none
    }
}

public protocol WithAccountErrorAction {
    static func accountErrorAlert(_ action: AccountErrorAlertAction) -> Self
}

public extension Reducer where Action: WithAccountErrorAction & Equatable {
    func accountErrorAlert(
        state toAlertState: WritableKeyPath<State, AlertState<AccountErrorAlertAction>?>
    ) -> Reducer<State, Action, Environment> {
        Reducer.combine([
            accountErrorAlertReducer.optional().pullback(
                state: toAlertState,
                action: CasePath(Action.accountErrorAlert),
                environment: { _ in () }
            ),
            Reducer { state, action, _ in
                switch action {
                case .accountErrorAlert(.show):
                    state[keyPath: toAlertState] = makeAlert()
                    return .none
                case .accountErrorAlert(.dismiss):
                    state[keyPath: toAlertState] = nil
                    return .none
                default:
                    return .none
                }
            },
            self,
        ])
    }
}

// MARK: State

private func makeAlert() -> AlertState<AccountErrorAlertAction> {
    AlertState(
        title: TextState(verbatim: l10n.title),
        message: TextState(verbatim: l10n.content),
        buttons: [
            .default(
                TextState(verbatim: l10n.TryAgainAction.title),
                action: .send(.tryAgainTapped)
            ),
            .default(
                TextState(verbatim: l10n.GoToAccountSettingsAction.title),
                action: .send(.goToAccountSettingsTapped)
            ),
            .default(
                TextState(verbatim: l10n.WorkOfflineAction.title),
                action: .send(.workOfflineTapped)
            ),
        ]
    )
}

// MARK: Actions

public enum AccountErrorAlertAction: Equatable {
    case show, dismiss
    case tryAgainTapped, goToAccountSettingsTapped, workOfflineTapped
}

// MARK: - Previews

struct AccountErrorAlert_Previews: PreviewProvider {
    struct Preview: View {
        struct State: Equatable {
            var alert: AlertState<AccountErrorAlertAction>?
            var isShowingAlert: Bool { self.alert != nil }
        }

        enum Action: Equatable, WithAccountErrorAction {
            case accountErrorAlert(AccountErrorAlertAction)
        }

        static let reducer = Reducer<State, Action, Void>.empty
            .accountErrorAlert(state: \.alert)

        let store: Store<State, Action>

        var body: some View {
            WithViewStore(self.store) { viewStore in
                Button("Show alert") { viewStore.send(.accountErrorAlert(.show)) }
                    .disabled(viewStore.isShowingAlert)
                    .padding()
                    .accountErrorAlert(self.store.scope(state: \.alert))
            }
        }
    }

    static var previews: some View {
        Preview(store: Store(
            initialState: .init(),
            reducer: Preview.reducer,
            environment: ()
        ))
    }
}
