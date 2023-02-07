//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import CustomDump
import ProseCore

/// JIDs, as defined in [XEP-0029](https://xmpp.org/extensions/xep-0029.html).
public struct JID: Hashable {
  public let bareJid: BareJid
}

public extension JID {
  init(string: String) throws {
    self.bareJid = try ProseCore.parseJid(jid: string)
  }

  init(fullJid: FullJid) {
    self.bareJid = .init(node: fullJid.node, domain: fullJid.domain)
  }
}

extension JID: RawRepresentable {
  public var rawValue: String {
    ProseCore.formatJid(jid: self.bareJid)
  }

  public init?(rawValue: String) {
    do {
      self.bareJid = try ProseCore.parseJid(jid: rawValue)
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

  var node: String? {
    self.bareJid.node
  }

  var domain: String {
    self.bareJid.domain
  }
}

extension JID: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.rawValue)
  }
}

extension JID: CustomDumpRepresentable {
  public var customDumpValue: Any {
    self.rawValue
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
