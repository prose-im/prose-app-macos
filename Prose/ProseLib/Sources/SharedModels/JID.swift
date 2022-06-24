//
//  JID.swift
//  Prose
//
//  Created by Rémi Bardon on 07/06/2022.
//

import Foundation

/// JIDs, as defined in [XEP-0029](https://xmpp.org/extensions/xep-0029.html).
public struct JID: Hashable {
    public let node: String?
    public let domain: String
    public let resource: String?

    public init(node: String?, domain: String, resource: String?) {
        self.node = node
        self.domain = domain
        self.resource = resource
    }
}

public extension JID {
    var jidString: String {
        Self.print(self)
    }
}

extension JID: CustomStringConvertible {
    public var description: String { self.jidString }
}

extension JID: RawRepresentable {
    public var rawValue: String { self.jidString }
    public init(rawValue: String) {
        self = Self.parse(rawValue)
    }
}

extension JID: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = Self.parse(value)
    }
}

extension JID: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(Self.print(self))
    }
}

extension JID: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = Self.parse(string)
    }
}

extension JID {
    /// Naive JID parser
    static func parse(_ string: String) -> JID {
        var domainRange = string.startIndex..<string.endIndex

        let node: String?
        if let index = string.firstIndex(of: "@") {
            node = String(string.prefix(upTo: index))
            domainRange = string.index(after: index)..<domainRange.upperBound
        } else {
            node = nil
        }

        let resource: String?
        if let index = string.lastIndex(of: "/") {
            resource = String(string.suffix(from: string.index(after: index)))
            domainRange = domainRange.lowerBound..<index
        } else {
            resource = nil
        }

        let domain = String(string[domainRange])

        return JID(node: node, domain: domain, resource: resource)
    }

    static func print(_ jid: JID) -> String {
        "\(jid.node.map { "\($0)@" } ?? "")\(jid.domain)\(jid.resource.map { "/\($0)" } ?? "")"
    }
}
