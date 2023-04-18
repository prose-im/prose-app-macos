//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import Foundation

public struct FFI {
  public let messagingContext: MessagingContext
  public let messagingStore: MessagingStore

  public init(evaluator: @escaping JSEvaluator) {
    self.messagingContext = MessagingContext(evaluator: evaluator)
    self.messagingStore = MessagingStore(evaluator: evaluator)
  }
}
