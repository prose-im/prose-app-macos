//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import ProseCore
import ComposableArchitecture

public struct CredentialsClient {
  public var loadCredentials: (_ jid: BareJid) throws -> Credentials?
  public var save: (_ credentials: Credentials) throws -> Void
  public var deleteCredentials: (_ jid: BareJid) throws -> Void
}

public extension DependencyValues {
  var credentialsClient: CredentialsClient {
    get { self[CredentialsClient.self] }
    set { self[CredentialsClient.self] = newValue }
  }
}

extension CredentialsClient: TestDependencyKey {
  public static var testValue = CredentialsClient(
    loadCredentials: unimplemented("\(Self.self).loadCredentials"),
    save: unimplemented("\(Self.self).save"),
    deleteCredentials: unimplemented("\(Self.self).deleteCredentials")
  )
}
