//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import Foundation

public extension RNDResult {
  static func all() -> [RNDResult] {
    let data = try! Data(
      contentsOf: Foundation.Bundle.module
        .url(forResource: "random_user", withExtension: "json")!
    )
    return try! JSONDecoder().decode(RNDRandomUserResponse.self, from: data).results
  }
}
