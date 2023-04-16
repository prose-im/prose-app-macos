//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import CredentialsClient
import ProseCoreTCA
import SwiftUI

#warning("FIXME")

// struct MFAView: View {
//  typealias State = MFAState
//  typealias Action = MFAAction
//
//  let store: Store<State, Action>
//  private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }
//
//  var body: some View {
//    SwitchStore(self.store) {
//      CaseLet(
//        state: CasePath(State.sixDigits).extract(from:),
//        action: Action.sixDigits,
//        then: MFA6DigitsView.init(store:)
//      )
//    }
//  }
// }
//
//// MARK: - The Composable Architecture
//
//// MARK: Reducer
//
// struct AuthenticationEnvironment {
//  var proseClient: ProseClient
//  var credentials: CredentialsClient
//  var mainQueue: AnySchedulerOf<DispatchQueue>
// }
//
// let mfaReducer: AnyReducer<
//  MFAState,
//  MFAAction,
//  AuthenticationEnvironment
// > = AnyReducer.combine([
//  mfa6DigitsReducer.pullback(
//    state: CasePath(MFAState.sixDigits),
//    action: CasePath(MFAAction.sixDigits),
//    environment: { $0 }
//  ),
//  AnyReducer { _, action, _ in
//    switch action {
//    case let .sixDigits(.verifyOneTimeCodeResult(.success(route))):
//      return EffectTask(value: .didPassChallenge(next: route))
//
//    default:
//      break
//    }
//
//    return .none
//  },
// ])
//
//// MARK: State
//
// public enum MFAState: Equatable {
//  case sixDigits(MFA6DigitsState)
// }
//
//// MARK: Actions
//
// public enum MFAAction: Equatable {
//  case didPassChallenge(next: Authentication.Route)
//  case sixDigits(MFA6DigitsAction)
// }
