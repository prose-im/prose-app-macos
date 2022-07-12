//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Combine
import ComposableArchitecture
import Foundation
import Toolbox

public extension Publisher where Failure == Never {
  func eraseToFailingEffect() -> Effect<Output, EquatableError> {
    self.setFailureType(to: EquatableError.self).eraseToEffect()
  }
}
