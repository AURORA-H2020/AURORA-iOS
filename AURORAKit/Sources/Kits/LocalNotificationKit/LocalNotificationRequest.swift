import CoreLocation
import Foundation
import UserNotifications

// MARK: - LocalNotificationRequest

/// A LocalNotificationRequest
public struct LocalNotificationRequest: Hashable, Identifiable {
    
    // MARK: Properties
    
    /// The identifier.
    public var id: String
    
    /// The UNMutableNotificationContent
    public var content: UNMutableNotificationContent
    
    /// The optional Trigger.
    public var trigger: Trigger?
    
    // MARK: Initializer
    
    /// Creates a new instance of `LocalNotificationRequest`
    /// - Parameters:
    ///   - id: The identifier
    ///   - content: The UNMutableNotificationContent
    ///   - trigger: The optional Trigger. Default value `nil`
    public init(
        id: String,
        content: UNMutableNotificationContent,
        trigger: Trigger? = nil
    ) {
        self.id = id
        self.content = content
        self.trigger = trigger
    }
    
}

// MARK: - Convenience Initializer

public extension LocalNotificationRequest {
    
    /// Creates a new instance of `LocalNotificationRequest`
    /// - Parameters:
    ///   - id: The identifier
    ///   - trigger: The optional Trigger. Default value `nil`
    ///   - content: A closure which takes in a UNMutableNotificationContent for configuration.
    init(
        id: String,
        trigger: Trigger? = nil,
        content: (UNMutableNotificationContent) -> Void
    ) {
        self.init(
            id: id,
            content: {
                let notificationContent = UNMutableNotificationContent()
                content(notificationContent)
                return notificationContent
            }(),
            trigger: trigger
        )
    }
    
}

// MARK: - Raw Value

public extension LocalNotificationRequest {
    
    /// The raw `UNNotificationRequest` value.
    var rawValue: UNNotificationRequest {
        .init(
            identifier: self.id,
            content: self.content,
            trigger: self.trigger?.rawValue
        )
    }
    
}

// MARK: - Trigger

public extension LocalNotificationRequest {
    
    /// A LocalNotificationRequest Trigger.
    enum Trigger: Hashable {
        /// TimeInterval
        case timeInterval(
            after: Measurement<UnitDuration>,
            repeats: Bool = false
        )
        /// Calendar
        case calendar(
            dateMatching: DateComponents,
            repeats: Bool = false
        )
        /// Location
        case location(
            region: CLRegion,
            repeats: Bool = false
        )
    }
    
}

// MARK: - Trigger+rawValue

public extension LocalNotificationRequest.Trigger {
    
    /// The raw `UNNotificationTrigger` value.
    var rawValue: UNNotificationTrigger {
        switch self {
        case .timeInterval(let after, let repeats):
            return UNTimeIntervalNotificationTrigger(
                timeInterval: .init(after.converted(to: .seconds).value),
                repeats: repeats
            )
        case .calendar(let dateMatching, let repeats):
            return UNCalendarNotificationTrigger(
                dateMatching: dateMatching,
                repeats: repeats
            )
        case .location(let region, let repeats):
            return UNLocationNotificationTrigger(
                region: region,
                repeats: repeats
            )
        }
    }
    
}

// MARK: - UNMutableNotificationContent+init(title:)

public extension UNMutableNotificationContent {
    
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
        filterCriteria.flatMap { self.filterCriteria = $0 }
        threadIdentifier.flatMap { self.threadIdentifier = $0 }
        categoryIdentifier.flatMap { self.categoryIdentifier = $0 }
    }
    
}
