import Foundation

// Source: https://twittemb.github.io/posts/2021-12-10-EquatableError/
public struct EquatableError: LocalizedError, Hashable, CustomStringConvertible {
    public let base: Error

    private let equals: (Error) -> Bool
    private let hash: (inout Hasher) -> Void

    public init<Base: Error>(_ base: Base) {
        self.base = base
        self.equals = { String(reflecting: $0) == String(reflecting: base) }
        self.hash = { $0.combine(String(reflecting: base)) }
    }

    public init<Base: Error & Equatable>(_ base: Base) {
        self.base = base
        self.equals = { ($0 as? Base) == base }
        self.hash = { $0.combine(String(reflecting: base)) }
    }

    public init<Base: Error & Hashable>(_ base: Base) {
        self.base = base
        self.equals = { ($0 as? Base) == base }
        self.hash = base.hash(into:)
    }

    public static func == (lhs: EquatableError, rhs: EquatableError) -> Bool {
        lhs.equals(rhs.base)
    }

    public var description: String {
        "\(self.base)"
    }

    public var localizedDescription: String {
        // NOTE: [Rémi Bardon] I don't know why this was here, so I commented it out.
//        print(self.base)
        self.base.localizedDescription
    }

    public func hash(into hasher: inout Hasher) {
        self.hash(&hasher)
    }
}

public extension Error where Self: Hashable {
    func eraseToEquatableError() -> EquatableError {
        EquatableError(self)
    }
}

public extension Error where Self: Equatable {
    func eraseToEquatableError() -> EquatableError {
        EquatableError(self)
    }
}

public extension Error {
    func eraseToEquatableError() -> EquatableError {
        EquatableError(self)
    }
}
