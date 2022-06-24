#if DEBUG
    import Combine
    import ComposableArchitecture
    import Foundation
    import Toolbox

    public extension ProseClient {
        static let noop = ProseClient(
            login: { _, _ in Empty(completeImmediately: true).eraseToEffect() },
            logout: { _ in Empty(completeImmediately: true).eraseToEffect() },
            roster: { Empty(completeImmediately: false).eraseToEffect() },
            messagesInChat: { _ in Just([]).eraseToEffect() },
            sendMessage: { _, _ in
                Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
            },
            markMessagesReadInChat: { _ in Empty(completeImmediately: true).eraseToEffect() }
        )
    }
#endif
