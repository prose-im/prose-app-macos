import Combine
import ComposableArchitecture
import Foundation
import Toolbox
import UserNotifications

public extension NotificationsClient {
    static let live: Self = {
        let permissionSubject = CurrentValueSubject<NotificationPermission, Never>(.notDetermined)

        func refreshNotificationPermission() {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                permissionSubject.send(.init(authorizationStatus: settings.authorizationStatus))
            }
        }

        refreshNotificationPermission()

        return .init(
            promptForPushNotifications: {
                let options: UNAuthorizationOptions = [.alert, .badge, .sound]

                UNUserNotificationCenter.current().requestAuthorization(
                    options: options,
                    completionHandler: { _, error in
                        if let error = error {
                            logger.error(
                                "Could not request authorization. \(error.localizedDescription, privacy: .public)"
                            )
                        }
                        refreshNotificationPermission()
                    }
                )
            },
            notificationPermission: {
                permissionSubject.eraseToEffect()
            },
            scheduleLocalNotification: { message in
                let content = UNMutableNotificationContent()
                content.title = message.from.jidString
                content.body = message.body
                content.sound = .default
                content.threadIdentifier = message.from.jidString

                let request = UNNotificationRequest(
                    identifier: UUID().uuidString,
                    content: content,
                    trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
                )

                UNUserNotificationCenter.current().add(request)

                return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
            }
        )
    }()
}

private extension NotificationPermission {
    init(authorizationStatus: UNAuthorizationStatus) {
        switch authorizationStatus {
        case .notDetermined:
            self = .notDetermined
        case .denied:
            self = .denied
        case .authorized:
            self = .authorized
        case .provisional:
            self = .provisional
        case .ephemeral:
            self = .ephemeral
        @unknown default:
            self = .notDetermined
        }
    }
}
