//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import ComposableArchitecture

public struct UnreadScreenReducer: ReducerProtocol {
  public typealias State = SessionState<UnreadScreenState>

  public struct UnreadScreenState: Equatable {
    var messages = [UnreadSectionModel]()

    public init() {}
  }

  public enum Action: Equatable {
    case onAppear
  }

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    Reduce { _, action in
      switch action {
      case .onAppear:
        return .none
      }
    }
  }
}
