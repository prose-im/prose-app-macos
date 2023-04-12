//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

// #if DEBUG
import Combine
import ComposableArchitecture
import Foundation
import Toolbox

public extension ProseClient {
  static let noop = ProseClient(
    login: { _, _ in Empty(completeImmediately: true).eraseToEffect() },
    logout: { _ in Empty(completeImmediately: true).eraseToEffect() },
    roster: { Empty(completeImmediately: false).eraseToEffect() },
    activeChats: { Empty(completeImmediately: false).eraseToEffect() },
    presence: { Empty(completeImmediately: false).eraseToEffect() },
    userInfos: { _ in Empty(completeImmediately: false).eraseToEffect() },
    incomingMessages: { Empty(completeImmediately: false).eraseToEffect() },
    messagesInChat: { _ in
      Just([]).setFailureType(to: EquatableError.self).eraseToEffect()
    },
    sendMessage: { _, _ in
      Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
    },
    updateMessage: { _, _, _ in
      Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
    },
    addReaction: { _, _, _ in
      Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
    },
    toggleReaction: { _, _, _ in
      Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
    },
    retractMessage: { _, _ in
      Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
    },
    sendChatState: { _, _ in
      Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
    },
    sendPresence: { _, _ in
      Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
    },
    markMessagesReadInChat: { _ in Empty(completeImmediately: true).eraseToEffect() },
    fetchPastMessagesInChat: { _ in Empty(completeImmediately: true).eraseToEffect() },
    setAvatarImage: { _ in Empty(completeImmediately: true).eraseToEffect() }
  )
}

// #endif
