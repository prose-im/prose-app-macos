//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import ProseCoreFFI

public struct ChatState: Equatable {
  public var kind: Kind
  public var timestamp: Date

  public init(kind: ChatState.Kind, timestamp: Date) {
    self.kind = kind
    self.timestamp = timestamp
  }
}

public extension ChatState {
  /// See: https://xmpp.org/extensions/xep-0085.html
  enum Kind: Equatable {
    case active
    case composing
    case gone
    case inactive
    case paused
  }
}

// extension ChatState {
//  init(state: XmppChatState, timestamp: Date) {
//    switch state {
//    case .active:
//      self.kind = .active
//    case .composing:
//      self.kind = .composing
//    case .gone:
//      self.kind = .gone
//    case .inactive:
//      self.kind = .inactive
//    case .paused:
//      self.kind = .paused
//    @unknown default:
//      fatalError("Unknown ChatState \(state)")
//    }
//    self.timestamp = timestamp
//  }
// }
//
// extension ChatState.Kind {
//  var ffi: XmppChatState {
//    switch self {
//    case .active:
//      return .active
//    case .composing:
//      return .composing
//    case .gone:
//      return .gone
//    case .inactive:
//      return .inactive
//    case .paused:
//      return .paused
//    }
//  }
// }
