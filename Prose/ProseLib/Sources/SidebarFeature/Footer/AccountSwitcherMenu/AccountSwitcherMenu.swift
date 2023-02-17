import AppDomain
import ComposableArchitecture
import ProseCoreTCA

public struct AccountSwitcherMenu: ReducerProtocol {
  public typealias State = SessionState<AccountSwitcherMenuState>

  public struct AccountSwitcherMenuState: Equatable {
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
