//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppLocalization
import Foundation

public enum MFAError: Error, Equatable {
  case badCode
}

extension MFAError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .badCode:
      return "Bad code"
    }
  }
}
