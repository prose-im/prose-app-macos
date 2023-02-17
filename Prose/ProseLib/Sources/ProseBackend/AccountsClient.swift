import AppDomain
import Combine
import ComposableArchitecture

public struct AccountsClient {
  public var availableAccounts: () -> AsyncStream<[BareJid: Account]>

  /// Tries to connect to an account and adds it to `availableAccounts` if the connection
  /// was successful.
  public var tryConnectAccount: (Credentials) async throws -> Void

  /// Tries to connect to all accounts identified by each credential and adds them to
  /// `availableAccounts` regardless of the connection status.
  public var connectAccounts: ([Credentials]) -> Void

  /// Tries to reconnect an account with the given credentials. If the account wasn't connected
  /// before this method does nothing.
  public var reconnectAccount: (Credentials, _ retryAutomatically: Bool) -> Void

  /// Disconnects the account with the given JID and removes it from `availableAccounts`.
  public var disconnectAccount: (BareJid) async throws -> Void
}

public extension DependencyValues {
  var accountsClient: AccountsClient {
    get { self[AccountsClient.self] }
    set { self[AccountsClient.self] = newValue }
  }
}

extension AccountsClient: TestDependencyKey {
  public static var testValue = AccountsClient(
    availableAccounts: unimplemented("\(Self.self).availableAccounts"),
    tryConnectAccount: unimplemented("\(Self.self).tryConnectAccount"),
    connectAccounts: unimplemented("\(Self.self).connectAccounts"),
    reconnectAccount: unimplemented("\(Self.self).reconnectAccount"),
    disconnectAccount: unimplemented("\(Self.self).disconnectAccount")
  )
}
