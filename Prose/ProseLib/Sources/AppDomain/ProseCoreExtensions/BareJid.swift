//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import Foundation
import ProseCoreFFI

extension BareJid: RawRepresentable {
  public init?(rawValue: String) {
    guard let jid = try? parseJid(jid: rawValue) else {
      return nil
    }
    self = jid
  }

  public var rawValue: String {
    formatJid(jid: self)
  }
}

extension BareJid: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self = try parseJid(jid: container.decode(String.self))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.rawValue)
  }
}

#if DEBUG
  /// Use this for testing only, since we might crash otherwise.
  extension BareJid: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
      do {
        try self = parseJid(jid: value)
      } catch {
        fatalError(error.localizedDescription)
      }
    }
  }
#endif
