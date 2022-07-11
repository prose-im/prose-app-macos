//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Combine
import CombineSchedulers

public enum Cursor: Equatable {
  /// When hovering an interactive view (button, link…)
  case interactiveHover
}

public final class CursorClient {
  private let cursorSubject: PassthroughSubject<Cursor, Never> = PassthroughSubject()
  private let popSubject: PassthroughSubject<Void, Never> = PassthroughSubject()

  public let _push: (Cursor) -> Void
  public let _pop: () -> Void

  public func push(_ cursor: Cursor) {
    self.cursorSubject.send(cursor)
  }

  public func pop() {
    self.popSubject.send(())
  }

  var cancellables = Set<AnyCancellable>()

  init(
    push: @escaping (Cursor) -> Void,
    pop: @escaping () -> Void,
    mainQueue: AnySchedulerOf<DispatchQueue> = .main
  ) {
    self._push = push
    self._pop = pop
    Publishers.Merge(
      self.cursorSubject
        // Make sure we don't pop the cursor if a new one is coming
        .debounce(for: 0.125, scheduler: mainQueue)
        .map(Cursor?.some),
      self.popSubject
        .map { Cursor?.none }
    )
    .removeDuplicates()
    .receive(on: mainQueue)
    .sink { [weak self] (cursor: Cursor?) in
      if let cursor = cursor {
        self?._push(cursor)
      } else {
        self?._pop()
      }
    }
    .store(in: &self.cancellables)
  }
}
