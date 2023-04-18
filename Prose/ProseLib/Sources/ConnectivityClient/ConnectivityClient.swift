//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import ComposableArchitecture

public struct ConnectivityClient {
  public var connectivity: () -> AsyncStream<Connectivity>
}

public extension DependencyValues {
  var connectivityClient: ConnectivityClient {
    get { self[ConnectivityClient.self] }
    set { self[ConnectivityClient.self] = newValue }
  }
}

extension ConnectivityClient: TestDependencyKey {
  public static var testValue = ConnectivityClient(
    connectivity: unimplemented("\(Self.self).connectivity")
  )
}
