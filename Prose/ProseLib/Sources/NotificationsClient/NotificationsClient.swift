//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import Foundation
import ProseBackend
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
  public var notificationPermission: () -> EffectTask<NotificationPermission>
  public var scheduleLocalNotification: (Message, UserInfo) -> EffectPublisher<None, EquatableError>
}

public extension DependencyValues {
  var notificationsClient: NotificationsClient {
    get { self[NotificationsClient.self] }
    set { self[NotificationsClient.self] = newValue }
  }
}

extension NotificationsClient: TestDependencyKey {
  public static var testValue = NotificationsClient(
    promptForPushNotifications: unimplemented("\(Self.self).promptForPushNotifications"),
    notificationPermission: unimplemented("\(Self.self).notificationPermission"),
    scheduleLocalNotification: unimplemented("\(Self.self).scheduleLocalNotification")
  )
}
