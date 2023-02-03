import Foundation
import UserNotifications

// MARK: - UNMutableNotificationContent+init(title:)

extension UNMutableNotificationContent {
    
    /// Creates a new instance of `UNMutableNotificationContent`
    convenience init(
        title: String?,
        subtitle: String? = nil,
        body: String? = nil,
        attachments: [UNNotificationAttachment]? = nil,
        userInfo: [AnyHashable: Any]? = nil,
        launchImageName: String? = nil,
        badge: Int? = nil,
        targetContentIdentifier: String? = nil,
        sound: UNNotificationSound? = nil,
        interruptionLevel: UNNotificationInterruptionLevel? = nil,
        relevanceScore: Double? = nil,
        filterCriteria: String? = nil,
        threadIdentifier: String? = nil,
        categoryIdentifier: String? = nil
    ) {
        self.init()
        title.flatMap { self.title = $0 }
        subtitle.flatMap { self.subtitle = $0 }
        body.flatMap { self.body = $0 }
        attachments.flatMap { self.attachments = $0 }
        userInfo.flatMap { self.userInfo = $0 }
        launchImageName.flatMap { self.launchImageName = $0 }
        badge.flatMap { self.badge = .init(value: $0) }
        targetContentIdentifier.flatMap { self.targetContentIdentifier = $0 }
        sound.flatMap { self.sound = $0 }
        interruptionLevel.flatMap { self.interruptionLevel = $0 }
        relevanceScore.flatMap { self.relevanceScore = $0 }
        if #available(iOS 16.0, *) {
            filterCriteria.flatMap { self.filterCriteria = $0 }
        }
        threadIdentifier.flatMap { self.threadIdentifier = $0 }
        categoryIdentifier.flatMap { self.categoryIdentifier = $0 }
    }
    
}
