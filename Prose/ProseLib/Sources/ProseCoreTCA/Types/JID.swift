//
//  JID.swift
//  Prose
//
//  Created by Rémi Bardon on 07/06/2022.
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

extension JID: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
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

private extension JID {
    enum CodingKeys: String, CodingKey {
        case node
        case domain
    }
}

extension JID: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.bareJid.node, forKey: .node)
        try container.encode(self.bareJid.domain, forKey: .domain)
    }
}

extension JID: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.bareJid = try .init(
            node: container.decodeIfPresent(String.self, forKey: .node),
            domain: container.decode(String.self, forKey: .domain)
        )
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
