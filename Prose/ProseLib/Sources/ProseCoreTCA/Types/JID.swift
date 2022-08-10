//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import ProseCoreClientFFI

/// JIDs, as defined in [XEP-0029](https://xmpp.org/extensions/xep-0029.html).
public struct JID: Hashable {
  let bareJid: BareJid
}

public extension JID {
  init(string: String) throws {
    self.bareJid = try ProseCoreClientFFI.parseJid(jid: string)
  }
}

extension JID: RawRepresentable {
  public var rawValue: String {
    ProseCoreClientFFI.formatJid(jid: self.bareJid)
  }

  public init?(rawValue: String) {
    do {
      self.bareJid = try ProseCoreClientFFI.parseJid(jid: rawValue)
    } catch {
      return nil
    }
  }
}

extension JID: CustomStringConvertible {
  public var description: String {
    self.rawValue
  }
}

public extension JID {
  var jidString: String {
    self.rawValue
  }
}

extension JID: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.rawValue)
  }
}

#if DEBUG
  /// Use this for testing only, since we might crash otherwise.
  extension JID: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
      do {
        try self = .init(string: value)
      } catch {
        fatalError(error.localizedDescription)
      }
    }
  }
#endif
