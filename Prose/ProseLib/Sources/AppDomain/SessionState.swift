//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import BareMinimum
import CasePaths
import Foundation
import IdentifiedCollections

@dynamicMemberLookup
public struct SessionState<ChildState: Equatable>: Equatable {
  public private(set) var accounts: IdentifiedArrayOf<Account>

  public var selectedAccountId: BareJid
  public var childState: ChildState

  public init(
    selectedAccountId: BareJid,
    accounts: IdentifiedArrayOf<Account>,
    childState: ChildState
  ) {
    self.selectedAccountId = selectedAccountId
    self.accounts = accounts
    self.childState = childState
  }

  public subscript<T>(dynamicMember keyPath: WritableKeyPath<ChildState, T>) -> T {
    get { self.childState[keyPath: keyPath] }
    set { self.childState[keyPath: keyPath] = newValue }
  }
}

public extension SessionState {
  var selectedAccount: Account {
    get {
      self.accounts[id: self.selectedAccountId]
        .expect(
          "Selected account \(self.selectedAccountId.rawValue) could not be found in available accounts"
        )
    }
    set {
      // This is the limited set of properties that can be changed by child reducers…
      self.accounts[id: self.selectedAccountId]?.availability = newValue.availability
    }
  }
}

public extension SessionState {
  func get<T>(_ toLocalState: (ChildState) -> T) -> SessionState<T> {
    SessionState<T>(
      selectedAccountId: self.selectedAccountId,
      accounts: self.accounts,
      childState: toLocalState(self.childState)
    )
  }

  mutating func set<T>(_ keyPath: WritableKeyPath<ChildState, T>, _ newValue: SessionState<T>) {
    self.childState[keyPath: keyPath] = newValue.childState
    self.merge(newValue: newValue)
  }

  func get<T>(_ toLocalState: (ChildState) -> T?) -> SessionState<T>? {
    guard let localState = toLocalState(self.childState) else {
      return nil
    }
    return SessionState<T>(
      selectedAccountId: self.selectedAccountId,
      accounts: self.accounts,
      childState: localState
    )
  }

  mutating func set<T>(_ keyPath: WritableKeyPath<ChildState, T?>, _ newValue: SessionState<T>?) {
    guard let newValue else { return }
    self.childState[keyPath: keyPath] = newValue.childState
    self.merge(newValue: newValue)
  }

  func get<T>(_ toLocalState: CasePath<ChildState, T>) -> SessionState<T>? {
    guard let localState = toLocalState.extract(from: self.childState) else {
      return nil
    }
    return SessionState<T>(
      selectedAccountId: self.selectedAccountId,
      accounts: self.accounts,
      childState: localState
    )
  }

  mutating func set<T>(_ casePath: CasePath<ChildState, T>, _ newValue: SessionState<T>?) {
    guard let newValue else { return }
    self.childState = casePath.embed(newValue.childState)
    self.merge(newValue: newValue)
  }
}

private extension SessionState {
  mutating func merge<T>(newValue: SessionState<T>) {
    self.selectedAccountId = newValue.selectedAccountId
    self.selectedAccount = newValue.selectedAccount
  }
}
