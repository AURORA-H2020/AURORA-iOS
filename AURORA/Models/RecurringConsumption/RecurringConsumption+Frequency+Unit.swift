import Foundation

// MARK: - RecurringConsumption+Frequency+Unit

extension RecurringConsumption.Frequency {
    
    /// A recurring consumption frequency unit
    enum Unit: String, Codable, Hashable, CaseIterable, Sendable {
        /// Daily
        case daily
        /// Weekly
        case weekly
        /// Monthly
        case monthly
    }
    
}

// MARK: - Unit+localizedString

extension RecurringConsumption.Frequency.Unit {
    
    /// A localized string.
    var localizedString: String {
        switch self {
        case .daily:
            return .init(localized: "Daily")
        case .weekly:
            return .init(localized: "Weekly")
        case .monthly:
            return .init(localized: "Monthly")
        }
    }
    
}

// MARK: - Unit+Weekday

extension RecurringConsumption.Frequency.Unit {
    
    /// A Weekday.
    /// Starting from 1 to 7 where 1 equals monday and 7 equals sunday.
    enum Weekday: Int, Codable, Hashable, CaseIterable, Sendable {
        case monday = 1
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
        case sunday
    }
    
}

// MARK: - Unit+Weekday+localizedString

extension RecurringConsumption.Frequency.Unit.Weekday {
    
    /// A localized string.
    var localizedString: String {
        switch self {
        case .monday:
            return .init(localized: "Monday")
        case .tuesday:
            return .init(localized: "Tuesday")
        case .wednesday:
            return .init(localized: "Wednesday")
        case .thursday:
            return .init(localized: "Thursday")
        case .friday:
            return .init(localized: "Friday")
        case .saturday:
            return .init(localized: "Saturday")
        case .sunday:
            return .init(localized: "Sunday")
        }
    }
    
}
