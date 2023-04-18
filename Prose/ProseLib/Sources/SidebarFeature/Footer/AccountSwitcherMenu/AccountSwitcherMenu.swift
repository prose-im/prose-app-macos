//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import ComposableArchitecture

public struct AccountSwitcherMenu: ReducerProtocol {
  public typealias State = SessionState<AccountSwitcherMenuState>

  public struct AccountSwitcherMenuState: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case showMenuTapped
    case accountSelected(BareJid)
    case connectAccountTapped
    /// Only here for accessibility
    case manageServerTapped
  }

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    EmptyReducer()
  }
}
