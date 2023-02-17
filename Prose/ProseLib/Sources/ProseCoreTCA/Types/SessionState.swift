import AppDomain
import Foundation
import TcaHelpers

@dynamicMemberLookup
public struct SessionState<ChildState: Equatable>: Equatable {
  public let currentUser: UserInfo
  public let accounts: [BareJid: Account]

  public var childState: ChildState

  public init(currentUser: UserInfo, accounts: [BareJid: Account], childState: ChildState) {
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

  var selectedAccount: Account? {
    self.accounts[self.currentUser.jid]
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

  func get<StatePath: Path>(
    _ toLocalState: StatePath
  ) -> SessionState<StatePath.Value>? where StatePath.Root == ChildState {
    guard let localState = toLocalState.extract(from: self.childState) else {
      return nil
    }
    return SessionState<StatePath.Value>(
      currentUser: self.currentUser,
      accounts: self.accounts,
      childState: localState
    )
  }

  mutating func set<T>(_ keyPath: WritableKeyPath<ChildState, T>, _ newValue: SessionState<T>) {
    self.childState[keyPath: keyPath] = newValue.childState
  }

  mutating func set<StatePath: Path, T>(
    _ path: StatePath,
    _ newValue: SessionState<T>?
  ) where StatePath.Root == ChildState, T == StatePath.Value {
    if let newValue = newValue {
      path.set(into: &self.childState, newValue.childState)
    }
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
      currentUser: UserInfo = .init(jid: "hello@prose.org")
    ) -> Self {
      SessionState(currentUser: currentUser, accounts: [:], childState: childState)
    }
  }
#endif
