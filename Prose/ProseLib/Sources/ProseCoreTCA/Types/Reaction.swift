//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation

public struct Reaction:
  Codable,
  Hashable,
  RawRepresentable,
  CustomStringConvertible,
  ExpressibleByStringLiteral,
  CustomDebugStringConvertible
{
  public var rawValue: String

  public init(_ value: String) {
    self.rawValue = value
  }

  public init(stringLiteral value: String) {
    self.rawValue = value
  }

  public init(rawValue value: String) {
    self.rawValue = value
  }

  public var debugDescription: String {
    self.rawValue
  }

  public var description: String {
    self.rawValue
  }
}
