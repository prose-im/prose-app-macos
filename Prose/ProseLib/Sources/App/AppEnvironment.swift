//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AuthenticationFeature
import ComposableArchitecture
import CredentialsClient
import Foundation
import MainWindowFeature
import NotificationsClient
import ProseCore
import struct ProseCoreTCA.ProseClient
import Toolbox
import UserDefaultsClient

#if canImport(AppKit)
  import AppKit

  public typealias OpenURLConfiguration = NSWorkspace.OpenConfiguration
#else
  public typealias OpenURLConfiguration = Void
#endif

public struct AppEnvironment {
  var userDefaults: UserDefaultsClient
  var credentials: CredentialsClient

  var proseClient: ProseClient
  var notifications: NotificationsClient

  var mainQueue: AnySchedulerOf<DispatchQueue>

  var openURL: (URL, OpenURLConfiguration) -> Effect<Void, URLOpeningError>
}

public extension AppEnvironment {
  static var live: Self {
    Self(
      userDefaults: .live(.standard),
      credentials: .live(service: "org.prose.app"),
      proseClient: .live(provider: ProseCore.ProseClient.init),
      notifications: .live,
      mainQueue: .main,
      openURL: { url, openConfig -> Effect<Void, URLOpeningError> in
        Effect.future { callback in
          #if canImport(AppKit)
            NSWorkspace.shared.open(url, configuration: openConfig) { _, error in
              if let error = error {
                callback(.failure(.failedToOpen(EquatableError(error))))
              } else {
                callback(.success(()))
              }
            }
          #else
            #error("AppKit is not available, find another way to open an URL.")
          #endif
        }
      }
    )
  }
}

extension AppEnvironment {
  var auth: AuthenticationEnvironment {
    AuthenticationEnvironment(
      proseClient: self.proseClient,
      credentials: self.credentials,
      mainQueue: self.mainQueue
    )
  }

  var main: MainScreenEnvironment {
    MainScreenEnvironment(proseClient: self.proseClient, mainQueue: self.mainQueue)
  }
}
