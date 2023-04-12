//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import Foundation
import ProseCoreTCA

public struct ReactionPickerReducer: ReducerProtocol {
  public struct State: Equatable {
    let reactions: [Reaction] = "👋👉👍😂😢😭😍😘😊🤯❤️🙏😛🚀⚠️😀😌😇🙃🙂🤩🥳🤨🙁😳🤔😐👀✅❌"
      .map { Reaction(rawValue: String($0)) }
    var selected: Set<Reaction>

    let columnCount = 5
    let fontSize: CGFloat = 24
    let spacing: CGFloat = 4

    var width: CGFloat { self.fontSize * 1.5 }
    var height: CGFloat { self.width }

    public init(selected: Set<Reaction> = []) {
      self.selected = selected
    }
  }

  public enum Action: Equatable {
    case select(Reaction)
    case deselect(Reaction)
  }

  public init() {}

  @Dependency(\.mainQueue) var mainQueue

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case let .select(reaction):
        state.selected.insert(reaction)
        return .none
      case let .deselect(reaction):
        state.selected.remove(reaction)
        return .none
      }
    }
  }
}
