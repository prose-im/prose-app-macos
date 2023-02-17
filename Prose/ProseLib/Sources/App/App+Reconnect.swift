import ComposableArchitecture

extension ReducerProtocol<App.State, App.Action> {
  func reconnectAccountsIfNeeded() -> some ReducerProtocol<App.State, App.Action> {
    ReconnectAccounts(base: self)
  }
}

private struct ReconnectAccounts<
  Base: ReducerProtocol<App.State, App.Action>
>: ReducerProtocol {
  let base: Base

  @Dependency(\.credentialsClient) var credentials
  @Dependency(\.accountsClient) var accounts

  var body: some ReducerProtocol<App.State, App.Action> {
    self.core
    self.base
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case let .availableAccountsChanged(accounts):
        var effects = [EffectTask<Action>]()

        // If an account suddenly turns into an error state we try to reconnect it. This happens
        // with a backoff in the AccountsClient. If that fails the status will switch to
        // disconnected in which case we won't try again unless we detect that the connectivity
        // changes to online. If the account's status is .disconnected our user has the chance to
        // click the "Reconnect" button in the offline banner.
        for (jid, account) in accounts where account.status.isError {
          if state.availableAccounts[jid]?.status.isError == false {
            effects.append(.fireAndForget {
              if let credentials = try self.credentials.loadCredentials(jid) {
                self.accounts.reconnectAccount(credentials, true)
              }
            })
          }
        }
        return .merge(effects)

      case .connectivityChanged(.online):
        return .fireAndForget { [accounts = state.availableAccounts] in
          for account in accounts.values {
            guard let credentials = try self.credentials.loadCredentials(account.jid) else {
              continue
            }
            self.accounts.reconnectAccount(credentials, true)
          }
        }

      default:
        return .none
      }
    }
  }
}
