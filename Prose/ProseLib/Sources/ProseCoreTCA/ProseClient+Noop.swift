#if DEBUG
    import Combine
    import ComposableArchitecture
    import Foundation

    public extension ProseClient {
        static let noop = ProseClient(
            login: { _, _ in Empty(completeImmediately: true).eraseToEffect() },
            logout: { _ in Empty(completeImmediately: true).eraseToEffect() },
            roster: { Empty(completeImmediately: false).eraseToEffect() }
        )
    }
#endif
