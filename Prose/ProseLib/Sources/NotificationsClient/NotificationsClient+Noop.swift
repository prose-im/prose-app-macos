//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import Combine
import ComposableArchitecture
import Foundation

#if DEBUG
  public extension NotificationsClient {
    static var noop = NotificationsClient(
      promptForPushNotifications: {},
      notificationPermission: { Empty(completeImmediately: false).eraseToEffect() },
      scheduleLocalNotification: { _, _ in }
    )
  }
#endif
