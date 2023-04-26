//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import Combine
import ComposableArchitecture

public struct AccountsClient {
  /// Returns all added accounts
  public var accounts: () -> AsyncStream<Set<BareJid>>

  /// Instantiates a `ProseCoreClient` for each JID and adds the JIDs to `availableAccounts`.
  public var addAccount: (BareJid) -> Void

  /// Disconnects the account with the given JID and removes it from `availableAccounts`.
  public var removeAccount: (BareJid) -> Void

  /// Returns a `ProseCoreClient` for the given JID or throws if the JID wasn't added
  /// using `addAccount`.
  public var client: (BareJid) throws -> ProseCoreClient

  /// Adds an ephemeral account for which a `ProseCoreClient` can be requested via
  /// `ephemeralClient`. Ephemeral accounts are not included in `accounts` unless promoted
  /// via `promoteEphemeralAccount`. Throws if a non-ephemeral account was added already.
  ///
  /// Ephemeral accounts are used for verifying and modifying an account before it can be displayed
  /// and used as a regular account in the app.
  public var addEphemeralAccount: (BareJid) throws -> Void

  /// Disconnects and removes the ephemeral account with the given JID. Does nothing if no
  /// ephemeral with the JID was added.
  public var removeEphemeralAccount: (BareJid) -> Void

  /// Promotes an ephemeral account to `accounts`.
  public var promoteEphemeralAccount: (BareJid) throws -> Void

  /// Returns a `ProseCoreClient` for the given JID or throws if the JID wasn't added
  /// using `addEphemeralAccount`.
  public var ephemeralClient: (BareJid) throws -> ProseCoreClient
}

public extension DependencyValues {
  var accountsClient: AccountsClient {
    get { self[AccountsClient.self] }
    set { self[AccountsClient.self] = newValue }
  }
}

extension AccountsClient: TestDependencyKey {
  public static var testValue = AccountsClient(
    accounts: unimplemented("\(Self.self).accounts"),
    addAccount: unimplemented("\(Self.self).addAccount"),
    removeAccount: unimplemented("\(Self.self).removeAccount"),
    client: unimplemented("\(Self.self).client"),
    addEphemeralAccount: unimplemented("\(Self.self).addEphemeralAccount"),
    removeEphemeralAccount: unimplemented("\(Self.self).removeEphemeralAccount"),
    promoteEphemeralAccount: unimplemented("\(Self.self).promoteEphemeralAccount"),
    ephemeralClient: unimplemented("\(Self.self).ephemeralClient")
  )
}

public extension AccountsClient {
  static let noop = AccountsClient(
    accounts: { AsyncStream.empty() },
    addAccount: { _ in },
    removeAccount: { _ in },
    client: { _ in throw AccountError.unknownAccount },
    addEphemeralAccount: { _ in },
    removeEphemeralAccount: { _ in },
    promoteEphemeralAccount: { _ in },
    ephemeralClient: { _ in throw AccountError.unknownAccount }
  )
}
