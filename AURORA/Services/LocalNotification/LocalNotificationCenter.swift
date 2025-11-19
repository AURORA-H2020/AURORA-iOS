import UIKit

// MARK: - LocalNotificationCenter

/// A LocalNotificationCenter
struct LocalNotificationCenter {
    
    // MARK: Static-Properties
    
    /// The LocalNotificationCenter for the current app.
    static let current = LocalNotificationCenter()
    
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
    init(
        application: UIApplication = .shared,
        notificationCenter: UNUserNotificationCenter = .current()
    ) {
        self.application = application
        self.notificationCenter = notificationCenter
    }
    
}

// MARK: - Authorization

extension LocalNotificationCenter {
    
    /// The UNAuthorizationStatus.
    var authorizationStatus: UNAuthorizationStatus {
        get async {
            await self.notificationSettings.authorizationStatus
        }
    }
    
    /// Bool value if notifications are authorized.
    var isAuthorized: Bool {
        get async {
            switch await self.authorizationStatus {
            case .denied, .notDetermined:
                return false
            default:
                return true
            }
        }
    }
    
    /// Request authorization.
    /// This function returns a Bool value specifying if the authorization was granted by the user.
    /// - Parameter options: The UNAuthorizationOptions. Default value `[.alert, .sound, .badge]`
    /// - Returns: A Bool value if the authorization was granted by the user.
    func requestAuthorization(
        options: UNAuthorizationOptions = [.alert, .sound, .badge]
    ) async throws -> Bool {
        try await self.notificationCenter
            .requestAuthorization(options: options)
    }
    
}

// MARK: - Notification Settings

extension LocalNotificationCenter {
    
    /// The UNNotificationSettings
    var notificationSettings: UNNotificationSettings {
        get async {
            await self.notificationCenter
                .notificationSettings()
        }
    }
    
}

// MARK: - Notification Categories

extension LocalNotificationCenter {
    
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

extension LocalNotificationCenter {
    
    /// Adds a new UNNotificationRequest.
    /// - Parameter request: The UNNotificationRequest to add.
    func add(
        _ request: UNNotificationRequest
    ) async throws {
        if await !self.isAuthorized {
            guard try await self.requestAuthorization() else {
                throw UNError(.notificationsNotAllowed)
            }
        }
        try await self.notificationCenter.add(request)
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

extension LocalNotificationCenter {
    
    /// The pending LocalNotificationRequest.
    var pendingNotificationRequests: [LocalNotificationRequest] {
        get async {
            await self.notificationCenter
                .pendingNotificationRequests()
                .map(LocalNotificationRequest.init)
        }
    }
    
    /// Retrieve a pending LocalNotificationRequest by its identifier.
    /// - Parameter id: The LocalNotificationRequest identifier.
    func pendingNotificationRequest(
        _ id: LocalNotificationRequest.ID
    ) async -> LocalNotificationRequest? {
        await self.pendingNotificationRequests.first { $0.id == id }
    }
    
}

// MARK: - Remove Pending Notification Requests

extension LocalNotificationCenter {
    
    /// Remove pending notification request.
    /// - Parameter request: The notification request to remove.
    func removePendingNotificationRequest(
        _ request: LocalNotificationRequest
    ) {
        self.removePendingNotificationRequest(request.id)
    }
    
    /// Remove pending notification requests.
    /// - Parameter requests: The notification requests to remove.
    func removePendingNotificationRequests<Requests: Sequence>(
        _ requests: Requests
    ) where Requests.Element == LocalNotificationRequest {
        self.removePendingNotificationRequests(requests.map(\.id))
    }
    
    /// Remove pending notification request.
    /// - Parameter identifier: The notification request identifier to remove.
    func removePendingNotificationRequest(
        _ identifier: LocalNotificationRequest.ID
    ) {
        self.notificationCenter
            .removePendingNotificationRequests(
                withIdentifiers: [identifier.rawValue]
            )
    }
    
    /// Remove pending notification requests.
    /// - Parameter identifiers: The notification request identifiers to remove.
    func removePendingNotificationRequests(
        _ identifiers: [LocalNotificationRequest.ID]
    ) {
        self.notificationCenter
            .removePendingNotificationRequests(
                withIdentifiers: identifiers.map(\.rawValue)
            )
    }
    
    /// Remove all pending notification requests
    func removeAllPendingNotificationRequests() {
        self.notificationCenter
            .removeAllPendingNotificationRequests()
    }
    
}

// MARK: - Delivered Notifications

extension LocalNotificationCenter {
    
    /// The delivered UNNotifications.
    var deliveredNotifications: [UNNotification] {
        get async {
            await self.notificationCenter
                .deliveredNotifications()
        }
    }
    
}

// MARK: - Remove Delivered Notifications

extension LocalNotificationCenter {
    
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

extension LocalNotificationCenter {
    
    /// The badge count
    var badgeCount: Int {
        self.application.applicationIconBadgeNumber
    }
    
    /// Set badge count.
    /// - Parameter badgeCount: The new badge count.
    func set(
        badgeCount: Int
    ) async throws {
        try await self.notificationCenter.setBadgeCount(badgeCount)
    }
    
    /// Reset badge count to zero.
    func resetBadgeCount() async throws {
        try await self.set(badgeCount: 0)
    }
    
    /// The next suitable badge count
    var nextBadgeCount: Int {
        get async {
            await self.pendingNotificationRequests.count + 1
        }
    }
    
}
