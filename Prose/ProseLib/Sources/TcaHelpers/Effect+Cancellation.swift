//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import Foundation

public extension Effect {
  // Source: https://forums.swift.org/t/ifletstore-and-effect-cancellation-on-view-disappear/38272/23
  static func cancel<T>(token: T.Type) -> Effect where T: CaseIterable, T: Hashable {
    .merge(token.allCases.map(Effect.cancel(id:)))
  }
}
