import Foundation
import UserNotifications

// MARK: - LocalNotificationRequest

/// A LocalNotificationRequest
public struct LocalNotificationRequest: Hashable, Identifiable {
    
    // MARK: Properties
    
    /// The identifier.
    public var id: ID
    
    /// The UNNotificationContent.
    public var content: UNNotificationContent
    
    /// The optional Trigger.
    public var trigger: Trigger?
    
    // MARK: Initializer
    
    /// Creates a new instance of `LocalNotificationRequest`
    /// - Parameters:
    ///   - id: The identifier
    ///   - notificationContent: The UNNotificationContent.
    ///   - trigger: The optional Trigger. Default value `nil`
    public init(
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

public extension LocalNotificationRequest {
    
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

public extension LocalNotificationRequest {
    
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

// MARK: - Badge Count

public extension LocalNotificationRequest {
    
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
