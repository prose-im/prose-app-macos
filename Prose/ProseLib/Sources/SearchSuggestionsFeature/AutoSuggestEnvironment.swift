//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AutoSuggestClient
import CombineSchedulers

public struct AutoSuggestEnvironment<T: Hashable> {
  /// The client performing search queries.
  var client: AutoSuggestClient<T>

  /// A reference to the main queue.
  var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(client: AutoSuggestClient<T>, mainQueue: AnySchedulerOf<DispatchQueue>) {
    self.client = client
    self.mainQueue = mainQueue
  }
}
