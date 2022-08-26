//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import Foundation
import ProseCoreTCA
import Toolbox

public enum NotificationPermission: Equatable {
  case notDetermined
  case denied
  case authorized
  case provisional
  case ephemeral
}

public struct NotificationsClient {
  public var promptForPushNotifications: () -> Void
  public var notificationPermission: () -> Effect<NotificationPermission, Never>
  public var scheduleLocalNotification: (Message, UserInfo) -> Effect<None, EquatableError>
}
