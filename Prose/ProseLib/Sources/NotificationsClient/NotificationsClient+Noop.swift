import Combine
import ComposableArchitecture
import Foundation
import Toolbox

#if DEBUG
    public extension NotificationsClient {
        static var noop = NotificationsClient(
            promptForPushNotifications: {},
            notificationPermission: { Empty(completeImmediately: false).eraseToEffect() },
            scheduleLocalNotification: { _ in
                Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
            }
        )
    }
#endif
