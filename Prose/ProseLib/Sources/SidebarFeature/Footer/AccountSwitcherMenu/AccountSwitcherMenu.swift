import ComposableArchitecture

public struct AccountSwitcherMenu: ReducerProtocol {
  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case showMenuTapped
    case switchAccountTapped(account: String)
    case connectAccountTapped
    /// Only here for accessibility
    case manageServerTapped
  }

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    EmptyReducer()
  }
}
