//
//  AppView.swift
//  Prose
//
//  Created by Valerian Saliou on 28/11/2021.
//

import AuthenticationFeature
import ComposableArchitecture
import MainWindowFeature
import SwiftUI

public struct AppView: View {
    public typealias State = AppState
    public typealias Action = AppAction

    private let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    // swiftlint:disable:next type_contents_order
    public init(store: Store<State, Action> = Store(
        initialState: AppState(),
        reducer: appReducer,
        environment: AppEnvironment.live
    )) {
        self.store = store
    }

    public var body: some View {
        SwitchStore(self.store.scope(state: \State.route)) {
            CaseLet(state: /AppRoute.auth, action: AppAction.auth, then: AuthenticationView.init(store:))
            CaseLet(state: /AppRoute.main, action: AppAction.main, then: MainWindow.init(store:))
        }
        .frame(minWidth: 1_280, minHeight: 720)
    }
}
