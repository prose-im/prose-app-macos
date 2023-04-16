//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import SwiftUI

public struct SidebarRowReducer: ReducerProtocol {
  public struct State: Equatable, Identifiable {
    public let id: SidebarReducer.Selection

    let icon: String
    let headline: String
    let subheadline: String
    var isSelected = false

    var foregroundColor: Color { self.isSelected ? .white : .primary }
  }

  public enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
  }

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
  }
}
