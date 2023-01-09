import UIKit
import UserNotifications

// MARK: - LocalNotificationCenter

/// A LocalNotificationCenter
public struct LocalNotificationCenter {
    
    // MARK: Static-Properties
    
    /// The LocalNotificationCenter for the current app.
    public static let current = LocalNotificationCenter()
    
    // MARK: Properties
    
    /// The UIApplication.
    private let application: UIApplication
    
    /// The UNUserNotificationCenter.
    private let notificationCenter: UNUserNotificationCenter
    
    // MARK: Initializer
    
    /// Creates a new instance of `LocalNotificationCenter`
    /// - Parameters:
    ///   - application: The UIApplication. Default value `.shared`
    ///   - notificationCenter: The UNUserNotificationCenter. Default value `.current()`
    public init(
        application: UIApplication = .shared,
        notificationCenter: UNUserNotificationCenter = .current()
    ) {
        self.application = application
        self.notificationCenter = notificationCenter
    }
    
}

// MARK: - Authorization

public extension LocalNotificationCenter {
    
    /// The UNAuthorizationStatus.
    var authorizationStatus: UNAuthorizationStatus {
        get async {
            await self.notificationSettings.authorizationStatus
        }
    }
    
    /// Bool value if notifications are authorized.
    var isAuthorized: Bool {
        get async {
            await self.authorizationStatus == .authorized
        }
    }
    
    /// Request authorization.
    /// This function returns a Bool value specifying if the authorization was granted by the user.
    /// - Parameter options: The UNAuthorizationOptions. Default value `.init()`
    /// - Returns: A Bool value if the authorization was granted by the user.
    func requestAuthorization(
        options: UNAuthorizationOptions = .init()
    ) async throws -> Bool {
        try await self.notificationCenter
            .requestAuthorization(options: options)
    }
    
}

// MARK: - Notification Settings

public extension LocalNotificationCenter {
    
    /// The UNNotificationSettings
    var notificationSettings: UNNotificationSettings {
        get async {
            await self.notificationCenter
                .notificationSettings()
        }
    }
    
}

// MARK: - Notification Categories

public extension LocalNotificationCenter {
    
    /// The UNNotificationCategories.
    var notificationCategories: Set<UNNotificationCategory> {
        get async {
            await self.notificationCenter
                .notificationCategories()
        }
    }
    
    /// Set UNNotificationCategories.
    /// - Parameter notificationCategories: The UNNotificationCategories to set.
    func set(
        notificationCategories: Set<UNNotificationCategory>
    ) {
        self.notificationCenter
            .setNotificationCategories(notificationCategories)
    }
    
}

// MARK: - Add Notification Request

public extension LocalNotificationCenter {
    
    /// Adds a new UNNotificationRequest.
    /// - Parameter request: The UNNotificationRequest to add.
    func add(
        _ request: UNNotificationRequest
    ) async throws {
        if await !self.isAuthorized {
            guard try await self.requestAuthorization() else {
                return
            }
        }
        try await self.notificationCenter
            .add(request)
    }
    
    /// Add a new LocalNotificationRequest
    /// - Parameter request: The LocalNotificationRequest to add.
    func add(
        _ request: LocalNotificationRequest
    ) async throws {
        try await self.add(request.rawValue)
    }
    
}

// MARK: - Pending Notification Requests

public extension LocalNotificationCenter {
    
    /// The pending UNNotificationRequests.
    var pendingNotificationRequests: [UNNotificationRequest] {
        get async {
            await self.notificationCenter
                .pendingNotificationRequests()
        }
    }
    
}

// MARK: - Delivered Notifications

public extension LocalNotificationCenter {
    
    /// The delivered UNNotifications.
    var deliveredNotifications: [UNNotification] {
        get async {
            await self.notificationCenter
                .deliveredNotifications()
        }
    }
    
}

// MARK: - Remove Pending Notification Requests

public extension LocalNotificationCenter {
    
    /// Remove pending notification requests.
    /// - Parameter identifiers: The notification request identifiers to remove.
    func removePendingNotificationRequests(
        identifiers: [String]
    ) {
        self.notificationCenter
            .removePendingNotificationRequests(
                withIdentifiers: identifiers
            )
    }
    
    /// Remove all pending notification requests
    func removeAllPendingNotificationRequests() {
        self.notificationCenter
            .removeAllPendingNotificationRequests()
    }
    
}

// MARK: - Remove Delivered Notifications

public extension LocalNotificationCenter {
    
    /// Remove delivered notifications.
    /// - Parameter identifiers: The notification identifiers to remove.
    func removeDeliveredNotifications(
        identifiers: [String]
    ) {
        self.notificationCenter
            .removeDeliveredNotifications(
                withIdentifiers: identifiers
            )
    }
    
    /// Remove all delivered notifications.
    func removeAllDeliveredNotifications() {
        self.notificationCenter
            .removeAllDeliveredNotifications()
    }
    
}

// MARK: - Badge Count

public extension LocalNotificationCenter {
    
    /// The badge count
    var badgeCount: Int {
        self.application.applicationIconBadgeNumber
    }
    
    /// Set badge count.
    /// - Parameter badgeCount: The new badge count.
    func set(
        badgeCount: Int
    ) async throws {
        if #available(iOS 16.0, *) {
            try await self.notificationCenter
                .setBadgeCount(badgeCount)
        } else {
            await MainActor.run {
                self.application.applicationIconBadgeNumber = badgeCount
            }
        }
    }
    
    /// Reset badge count to zero.
    func resetBadgeCount() async throws {
        try await self.set(badgeCount: 0)
    }
    
}
