import Combine
import Foundation

/// An equatable alternative to `Void`.
///
/// This is a fix for an issue that `Result<Void, RequestError>` can't be extended to
/// conform to `Equatable`.
public struct None: Hashable {
    public static let none = None()

    private init() {}
}

public extension Publisher {
    func mapVoidToNone() -> AnyPublisher<None, Failure> where Self.Output == Void {
        self.map { .none }.eraseToAnyPublisher()
    }
}
