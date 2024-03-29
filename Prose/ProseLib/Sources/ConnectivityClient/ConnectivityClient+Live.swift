//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import Combine
import ComposableArchitecture
import Network

extension ConnectivityClient {
  static let live: ConnectivityClient = {
    let connectivitySubject = CurrentValueSubject<Connectivity, Never>(Connectivity.online)
    let pathMonitorQueue = DispatchQueue(label: "org.prose.pathmonitor")
    let pathMonitor = NWPathMonitor()

    pathMonitor.pathUpdateHandler = { path in
      switch path.status {
      case .satisfied:
        connectivitySubject.send(.online)
      case .unsatisfied, .requiresConnection:
        connectivitySubject.send(.offline)
      @unknown default:
        connectivitySubject.send(.offline)
      }
    }

    pathMonitor.start(queue: pathMonitorQueue)

    return ConnectivityClient(connectivity: {
      AsyncStream(connectivitySubject.removeDuplicates().values)
    })
  }()
}

extension ConnectivityClient: DependencyKey {
  public static var liveValue = ConnectivityClient.live

  public static var previewValue = ConnectivityClient(
    connectivity: {
      AsyncStream(unfolding: { .online })
    }
  )
}
