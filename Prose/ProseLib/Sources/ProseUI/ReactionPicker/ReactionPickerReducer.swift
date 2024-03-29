//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import ComposableArchitecture
import Foundation

public struct ReactionPickerReducer: ReducerProtocol {
  public struct State: Equatable {
    let reactions: [Emoji] = "👋👉👍😂😢😭😍😘😊🤯❤️🙏😛🚀⚠️😀😌😇🙃🙂🤩🥳🤨🙁😳🤔😐👀✅❌"
      .map { Emoji(String($0)) }
    var selected: Set<Emoji>

    let columnCount = 5
    let fontSize: CGFloat = 24
    let spacing: CGFloat = 4

    var width: CGFloat { self.fontSize * 1.5 }
    var height: CGFloat { self.width }

    public init(selected: Set<Emoji> = []) {
      self.selected = selected
    }
  }

  public enum Action: Equatable {
    case select(Emoji)
    case deselect(Emoji)
  }

  public init() {}

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
