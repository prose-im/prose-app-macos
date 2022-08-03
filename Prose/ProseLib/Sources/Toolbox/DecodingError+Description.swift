//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation

extension DecodingError: CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
    case let .typeMismatch(_, context):
      return context.description
    case let .valueNotFound(_, context):
      return context.description
    case let .keyNotFound(_, context):
      return context.description
    case let .dataCorrupted(context):
      return context.description
    @unknown default:
      return self.localizedDescription
    }
  }
}

private extension DecodingError.Context {
  var description: String {
    "\(self.debugDescription) (Keypath: '\(self.codingPath.map(\.stringValue).joined(separator: "."))')"
  }
}
