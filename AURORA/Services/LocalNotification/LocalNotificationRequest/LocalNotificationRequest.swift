import Foundation
import UserNotifications

// MARK: - LocalNotificationRequest

/// A LocalNotificationRequest
struct LocalNotificationRequest: Hashable, Identifiable {
    
    // MARK: Properties
    
    /// The identifier.
    var id: ID
    
    /// The UNNotificationContent.
    var content: UNNotificationContent
    
    /// The optional Trigger.
    var trigger: Trigger?
    
    // MARK: Initializer
    
    /// Creates a new instance of `LocalNotificationRequest`
    /// - Parameters:
    ///   - id: The identifier
    ///   - notificationContent: The UNNotificationContent.
    ///   - trigger: The optional Trigger. Default value `nil`
    init(
        id: ID,
        notificationContent: UNNotificationContent,
        trigger: Trigger? = nil
    ) {
        self.id = id
        self.content = notificationContent
        self.trigger = trigger
    }
    
}

// MARK: - Convenience Initializers

extension LocalNotificationRequest {
    
    /// Creates a new instance of `LocalNotificationRequest`
    /// - Parameters:
    ///   - id: The identifier
    ///   - content: The UNMutableNotificationContent
    ///   - trigger: The optional Trigger. Default value `nil`
    init(
        id: ID,
        content: UNMutableNotificationContent,
        trigger: Trigger? = nil
    ) {
        self.init(
            id: id,
            notificationContent: content,
            trigger: trigger
        )
    }
    
    /// Creates a new instance of `LocalNotificationRequest`
    /// - Parameters:
    ///   - id: The identifier
    ///   - trigger: The optional Trigger. Default value `nil`
    ///   - content: A closure which takes in a UNMutableNotificationContent for configuration.
    init(
        id: ID,
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

extension LocalNotificationRequest {
    
    /// The raw `UNNotificationRequest` value.
    var rawValue: UNNotificationRequest {
        .init(
            identifier: self.id.rawValue,
            content: self.content,
            trigger: self.trigger?.rawValue
        )
    }
    
    /// Creates a new instance of `LocalNotificationRequest`
    /// - Parameter notificationRequest: The UNNotificationRequest.
    init(
        rawValue: UNNotificationRequest
    ) {
        self.init(
            id: .init(rawValue: rawValue.identifier),
            notificationContent: rawValue.content,
            trigger: rawValue.trigger.flatMap(Trigger.init)
        )
    }
    
}

// MARK: - Next Trigger Date

extension LocalNotificationRequest {
    
    /// The next date at which the trigger conditions are met.
    var nextTriggerDate: Date? {
        self.trigger?.nextTriggerDate
    }
    
}

// MARK: - Badge Count

extension LocalNotificationRequest {
    
    /// The badge count, if available.
    var badgeCount: Int? {
        get {
            self.content.badge?.intValue
        }
        set {
            (self.content as? UNMutableNotificationContent)?.badge = newValue.flatMap { NSNumber(value: $0) }
        }
    }
    
}
