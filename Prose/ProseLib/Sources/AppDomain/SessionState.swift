//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import BareMinimum
import CasePaths
import Foundation
import IdentifiedCollections

@dynamicMemberLookup
public struct SessionState<ChildState: Equatable>: Equatable {
  public let accounts: IdentifiedArrayOf<Account>

  public var currentUser: BareJid
  public var childState: ChildState

  public init(currentUser: BareJid, accounts: IdentifiedArrayOf<Account>, childState: ChildState) {
    self.currentUser = currentUser
    self.accounts = accounts
    self.childState = childState
  }

  public subscript<T>(dynamicMember keyPath: WritableKeyPath<ChildState, T>) -> T {
    get { self.childState[keyPath: keyPath] }
    set { self.childState[keyPath: keyPath] = newValue }
  }
}

public extension SessionState {
  var scoped: Scoped {
    Scoped(childState: self)
  }

  var selectedAccount: Account {
    self.accounts[id: self.currentUser]
      .expect(
        "Selected account \(self.currentUser.rawValue) could not be found in available accounts"
      )
  }
}

public extension SessionState {
  func get<T>(_ toLocalState: (ChildState) -> T) -> SessionState<T> {
    SessionState<T>(
      currentUser: self.currentUser,
      accounts: self.accounts,
      childState: toLocalState(self.childState)
    )
  }

  func get<T>(_ toLocalState: CasePath<ChildState, T>) -> SessionState<T>? {
    guard let localState = toLocalState.extract(from: self.childState) else {
      return nil
    }
    return SessionState<T>(
      currentUser: self.currentUser,
      accounts: self.accounts,
      childState: localState
    )
  }

  mutating func set<T>(_ keyPath: WritableKeyPath<ChildState, T>, _ newValue: SessionState<T>) {
    self.childState[keyPath: keyPath] = newValue.childState
    self.currentUser = newValue.currentUser
  }

  mutating func set<T>(_ casePath: CasePath<ChildState, T>, _ newValue: SessionState<T>?) {
    guard let newValue else { return }
    self.childState = casePath.embed(newValue.childState)
    self.currentUser = newValue.currentUser
  }
}

public extension SessionState {
  @dynamicMemberLookup
  struct Scoped {
    let childState: SessionState<ChildState>

    init(childState: SessionState<ChildState>) {
      self.childState = childState
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<ChildState, T>) -> SessionState<T> {
      self.childState.get { $0[keyPath: keyPath] }
    }
  }
}

#if DEBUG
  public extension SessionState {
    static func mock(
      _ childState: ChildState,
      currentUser: BareJid = "hello@prose.org"
    ) -> Self {
      SessionState(currentUser: currentUser, accounts: [], childState: childState)
    }
  }
#endif
