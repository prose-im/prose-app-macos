//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import ProseCore
import ProseCoreTCA

@dynamicMemberLookup
public struct ChatSessionState<ChildState: Equatable>: Equatable {
  public let currentUser: UserInfo
  public let chatId: BareJid
  public let userInfos: [BareJid: UserInfo]

  public var childState: ChildState

  public init(
    currentUser: UserInfo,
    chatId: BareJid,
    userInfos: [BareJid: UserInfo],
    childState: ChildState
  ) {
    self.currentUser = currentUser
    self.chatId = chatId
    self.userInfos = userInfos
    self.childState = childState
  }

  public subscript<T>(dynamicMember keyPath: WritableKeyPath<ChildState, T>) -> T {
    get { self.childState[keyPath: keyPath] }
    set { self.childState[keyPath: keyPath] = newValue }
  }
}

public extension ChatSessionState {
  var scoped: Scoped {
    Scoped(childState: self)
  }
}

public extension ChatSessionState {
  func get<T>(_ toLocalState: (ChildState) -> T) -> ChatSessionState<T> {
    ChatSessionState<T>(
      currentUser: self.currentUser,
      chatId: self.chatId,
      userInfos: self.userInfos,
      childState: toLocalState(self.childState)
    )
  }

  func get<T>(_ toLocalState: (ChildState) -> T?) -> ChatSessionState<T>? {
    guard let localState = toLocalState(self.childState) else {
      return nil
    }
    return ChatSessionState<T>(
      currentUser: self.currentUser,
      chatId: self.chatId,
      userInfos: self.userInfos,
      childState: localState
    )
  }

  mutating func set<T>(_ keyPath: WritableKeyPath<ChildState, T>, _ newValue: ChatSessionState<T>) {
    self.childState[keyPath: keyPath] = newValue.childState
  }

  mutating func set<T>(
    _ keyPath: WritableKeyPath<ChildState, T?>,
    _ newValue: ChatSessionState<T>?
  ) {
    self.childState[keyPath: keyPath] = newValue?.childState
  }
}

public extension ChatSessionState {
  @dynamicMemberLookup
  struct Scoped {
    let childState: ChatSessionState<ChildState>

    init(childState: ChatSessionState<ChildState>) {
      self.childState = childState
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<ChildState, T>) -> ChatSessionState<T> {
      self.childState.get { $0[keyPath: keyPath] }
    }
  }
}

#if DEBUG
  public extension ChatSessionState {
    static func mock(_ childState: ChildState) -> Self {
      ChatSessionState(
        currentUser: .init(jid: "hello@prose.org"),
        chatId: "chat@prose.org",
        userInfos: [:],
        childState: childState
      )
    }
  }
#endif
