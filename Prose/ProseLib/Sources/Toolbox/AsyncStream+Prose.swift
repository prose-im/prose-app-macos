//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

// Source: https://github.com/tgrapperon/swift-dependencies-additions/blob/bcb5e934a1b9a7d661ab5a9dce026015d5b03db4/Sources/DependenciesAdditionsBasics/ConcurrencySupport/AsyncStream%2BAdditions.swift

public extension AsyncStream {
  /// Produces an `AsyncStream` from an async `AsyncSequence` by awaiting and then consuming the
  /// sequence till it terminates, ignoring any failure.
  ///
  /// Useful as a kind of type eraser for actor-isolated live `AsyncSequence`-based dependencies,
  /// that also erases the `async` extraction.
  init<S: AsyncSequence>(_ sequence: @escaping () async throws -> S) rethrows
    where S.Element == Element
  {
    var iterator: S.AsyncIterator?
    self.init {
      if iterator == nil {
        iterator = try? await sequence().makeAsyncIterator()
      }
      return try? await iterator?.next()
    }
  }
}

public extension AsyncStream {
  static func empty() -> Self {
    .init(unfolding: { nil })
  }
}
