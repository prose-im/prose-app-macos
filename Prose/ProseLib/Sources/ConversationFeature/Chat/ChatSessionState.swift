//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import Foundation

@dynamicMemberLookup
public struct ChatSessionState<ChildState: Equatable>: Equatable {
  public let selectedAccountId: BareJid
  public let chatId: BareJid
  public let userInfos: [BareJid: Contact]
  public let composingUsers: [BareJid]

  public var childState: ChildState

  public init(
    selectedAccountId: BareJid,
    chatId: BareJid,
    userInfos: [BareJid: Contact],
    composingUsers: [BareJid],
    childState: ChildState
  ) {
    self.selectedAccountId = selectedAccountId
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
      selectedAccountId: self.selectedAccountId,
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
      selectedAccountId: self.selectedAccountId,
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
