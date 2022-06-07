//
//  JID.swift
//  Prose
//
//  Created by Rémi Bardon on 07/06/2022.
//

import Foundation
import Parsing

/// JIDs, as defined in [XEP-0029](https://xmpp.org/extensions/xep-0029.html).
///
/// Grammar:
/// ```grammar
/// <JID> ::= [<node>"@"]<domain>["/"<resource>]
/// <node> ::= <conforming-char>[<conforming-char>]*
/// <domain> ::= <hname>["."<hname>]*
/// <resource> ::= <any-char>[<any-char>]*
/// <hname> ::= <let>|<dig>[[<let>|<dig>|"-"]*<let>|<dig>]
/// <let> ::= [a-z] | [A-Z]
/// <dig> ::= [0-9]
/// <conforming-char> ::= #x21 | [#x23-#x25] | [#x28-#x2E] |
///                       [#x30-#x39] | #x3B | #x3D | #x3F |
///                       [#x41-#x7E] | [#x80-#xD7FF] |
///                       [#xE000-#xFFFD] | [#x10000-#x10FFFF]
/// <any-char> ::= [#x20-#xD7FF] | [#xE000-#xFFFD] |
///                [#x10000-#x10FFFF]
/// ```
public struct JID: Hashable {
    public let node: String?
    public let domain: String
    public let resource: String?
}

extension JID: CustomStringConvertible {
    public var description: String {
        (try? jidParserPrinter.print(self)).map(String.init) ?? "<error>"
    }
}

extension JID: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = try! jidParserPrinter.parse(value)
    }
}

private extension UTF8.CodeUnit {
    /// `<any-char> ::= [#x20-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]`
    var isAnyChar: Bool {
        switch UInt32(self) {
        case 0x20...0xD7FF, 0xE000...0xFFFD, 0x10000...0x10FFFF:
            return true
        default:
            return false
        }
    }

    /// ```grammar
    /// <conforming-char> ::= #x21 | [#x23-#x25] | [#x28-#x2E] |
    ///                       [#x30-#x39] | #x3B | #x3D | #x3F |
    ///                       [#x41-#x7E] | [#x80-#xD7FF] |
    ///                       [#xE000-#xFFFD] | [#x10000-#x10FFFF]
    /// ```
    var isConformingChar: Bool {
        switch UInt32(self) {
        case 0x21,
             0x23...0x25,
             0x28...0x2E,
             0x30...0x39,
             0x3B,
             0x3D,
             0x3F,
             0x41...0x7E,
             0x80...0xD7FF,
             0xE000...0xFFFD,
             0x10000...0x10FFFF:
            return true
        default:
            return false
        }
    }

    /// `<let> ::= [a-z] | [A-Z]`
    var isLetter: Bool {
        switch self {
        case .init(ascii: "A") ... .init(ascii: "Z"), .init(ascii: "a") ... .init(ascii: "z"):
            return true
        default:
            return false
        }
    }

    /// `<dig> ::= [0-9]`
    var isDigit: Bool {
        switch self {
        case .init(ascii: "0") ... .init(ascii: "9"):
            return true
        default:
            return false
        }
    }
}

/// `<hname> ::= <let>|<dig>[[<let>|<dig>|"-"]*<let>|<dig>]`
///
/// - Note: We cannot use `Many.init(element:separator:)`, as we could not have multiple separators
///         following each other.
private let hname = ParsePrint {
    Peek { Prefix(1) { $0.isLetter || $0.isDigit } }
    Many(into: "") { (string: inout String, fragment: (String, String)) in
        string.append(contentsOf: fragment.0)
        string.append(contentsOf: fragment.1)
    } decumulator: { (string: String) -> IndexingIterator<[(String, String)]> in
        var input = string[...]
        var res: [(String, String)] = []
        while !input.isEmpty {
            let letters = String(input.prefix(while: { $0 != "-" }))
            input = input.dropFirst(letters.count)
            let dashes = String(input.prefix(while: { $0 == "-" }))
            input = input.dropFirst(dashes.count)
            res.append((letters, dashes))
        }
        return res.reversed().makeIterator()
    } element: {
        Prefix(1...) { $0.isLetter || $0.isDigit }
            .map(.string)
        Prefix(1...) { $0 == UTF8.CodeUnit(ascii: "-") }
            .map(.string)
    }
    Prefix(1...) { $0.isLetter || $0.isDigit }
        .map(.string)
}
.map(.convert(
    apply: { (array: String, char: String) in array + char },
    unapply: { string -> (String, String)? in
        if let index = string.lastIndex(of: "-") {
            return (String(string[...index]), String(string[string.index(after: index)...]))
        } else {
            return ("", string)
        }
    }
))
.eraseToAnyParserPrinter()

/// [JID Node Identifier](https://xmpp.org/extensions/xep-0029.html#sect-idm45751618848896).
///
/// `<node> ::= <conforming-char>[<conforming-char>]*`
let jidNode = Prefix(1...) { $0.isConformingChar }
    .eraseToAnyParserPrinter()

/// `<domain> ::= <hname>["."<hname>]*`
let jidDomain = Many(1...) { hname } separator: { ".".utf8 }
    .map(.convert(
        apply: { $0.joined(separator: ".") },
        unapply: { $0.split(separator: ".").map(String.init) }
    ))
    .eraseToAnyParserPrinter()

/// `<resource> ::= <any-char>[<any-char>]*`
let jidResource = Prefix(1...) { $0.isAnyChar }

/// `<JID> ::= [<node>"@"]<domain>["/"<resource>]`
public let jidParserPrinter = ParsePrint {
    Optionally { From(.utf8) { jidNode }.map(.string); "@" }
    From(.utf8) { jidDomain }
    Optionally { "/"; From(.utf8) { jidResource }.map(.string) }
}
.map(.memberwise(JID.init))
.eraseToAnyParserPrinter()
