//
//  Box.swift
//  Prose
//
//  Created by Rémi Bardon on 02/05/2022.
//

import Combine

/// Just a class wrapper for a `struct`.
/// This allows storing a value in a TCA `State` without updating the `View`.
/// This also allows sharing a value across `State`s without the copy overhead.
@dynamicMemberLookup
public final class Box<WrappedValue>: ObservableObject {
    @Published public var wrappedValue: WrappedValue

    public init(_ wrappedValue: WrappedValue) {
        self.wrappedValue = wrappedValue
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<WrappedValue, T>) -> T {
        self.wrappedValue[keyPath: keyPath]
    }
}

extension Box: Equatable {
    public static func == (lhs: Box<WrappedValue>, rhs: Box<WrappedValue>) -> Bool {
        lhs === rhs
    }
}

public extension Box {
    convenience init<T>() where WrappedValue == T? {
        self.init(nil)
    }
}
