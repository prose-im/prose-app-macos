//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation

public enum JSEventError: Error, Equatable {
  case badSerialization, decodingError(String)
}

extension JSEventError: CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
    case .badSerialization:
      return "JS message body should be serialized as a String"
    case let .decodingError(debugDescription):
      return debugDescription
    }
  }
}
