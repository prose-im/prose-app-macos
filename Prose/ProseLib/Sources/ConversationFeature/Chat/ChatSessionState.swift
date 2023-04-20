//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import Foundation

@dynamicMemberLookup
public struct ChatSessionState<ChildState: Equatable>: Equatable {
  public let currentUser: BareJid
  public let chatId: BareJid
  public let userInfos: [BareJid: UserInfo]
  public let composingUsers: [BareJid]

  public var childState: ChildState

  public init(
    currentUser: BareJid,
    chatId: BareJid,
    userInfos: [BareJid: UserInfo],
    composingUsers: [BareJid],
    childState: ChildState
  ) {
    self.currentUser = currentUser
    self.chatId = chatId
    self.userInfos = userInfos
    self.composingUsers = composingUsers
    self.childState = childState
  }

  public subscript<T>(dynamicMember keyPath: WritableKeyPath<ChildState, T>) -> T {
    get { self.childState[keyPath: keyPath] }
    set { self.childState[keyPath: keyPath] = newValue }
  }
}

public extension ChatSessionState {
  func get<T>(_ toLocalState: (ChildState) -> T) -> ChatSessionState<T> {
    ChatSessionState<T>(
      currentUser: self.currentUser,
      chatId: self.chatId,
      userInfos: self.userInfos,
      composingUsers: self.composingUsers,
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
      composingUsers: self.composingUsers,
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

#if DEBUG
  public extension ChatSessionState {
    static func mock(_ childState: ChildState) -> Self {
      ChatSessionState(
        currentUser: "hello@prose.org",
        chatId: "chat@prose.org",
        userInfos: [:],
        composingUsers: [],
        childState: childState
      )
    }
  }
#endif
