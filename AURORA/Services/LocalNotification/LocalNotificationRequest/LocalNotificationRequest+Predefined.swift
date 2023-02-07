import SwiftUI
import UserNotifications

// MARK: - LocalNotificationRequest+Predefined

extension LocalNotificationRequest {
    
    /// A Predefined LocalNotificationRequest
    enum Predefined: String, Codable, Hashable, CaseIterable, Sendable {
        /// Electricity bill reminder
        case electricityBillReminder
        /// Heating bill reminder
        case heatingBillReminder
        /// Mobility reminder
        case mobilityReminder
    }
    
}

// MARK: - Identifiable

extension LocalNotificationRequest.Predefined: Identifiable {
    
    /// The LocalNotificationRequest ID.
    var id: LocalNotificationRequest.ID {
        switch self {
        case .electricityBillReminder:
            return "ElectricityBillReminder"
        case .heatingBillReminder:
            return "HeatingBillReminder"
        case .mobilityReminder:
            return "MobilityReminder"
        }
    }
    
}

// MARK: - Localized String

extension LocalNotificationRequest.Predefined {
    
    /// A localized string.
    var localizedString: String {
        switch self {
        case .electricityBillReminder:
            return .init(localized: "Electricity bill reminder")
        case .heatingBillReminder:
            return .init(localized: "Heating bill reminder")
        case .mobilityReminder:
            return .init(localized: "Mobility reminder")
        }
    }
    
}

// MARK: - Icon

extension LocalNotificationRequest.Predefined {
    
    /// The icon image.
    var icon: Image {
        switch self {
        case .electricityBillReminder:
            return .init(systemName: "bolt")
        case .heatingBillReminder:
            return .init(systemName: "heater.vertical")
        case .mobilityReminder:
            return .init(systemName: "car")
        }
    }
    
}

// MARK: - TintColor

extension LocalNotificationRequest.Predefined {
    
    /// The tint color.
    var tintColor: Color {
        switch self {
        case .electricityBillReminder:
            return Consumption
                .Category
                .electricity
                .tintColor
        case .heatingBillReminder:
            return Consumption
                .Category
                .heating
                .tintColor
        case .mobilityReminder:
            return Consumption
                .Category
                .transportation
                .tintColor
        }
    }
    
}

// MARK: - Content

extension LocalNotificationRequest.Predefined {
    
    /// The notification content
    var content: UNMutableNotificationContent {
        switch self {
        case .electricityBillReminder:
            return .init(
                title: .init(localized: "Electricity Bill Reminder"),
                body: .init(localized: "Add your electricity bill.")
            )
        case .heatingBillReminder:
            return .init(
                title: .init(localized: "Heating Bill Reminder"),
                body: .init(localized: "Add your heating bill.")
            )
        case .mobilityReminder:
            return .init(
                title: .init(localized: "Mobility Reminder"),
                body: .init(localized: "Add your mobility data.")
            )
        }
    }
    
}
