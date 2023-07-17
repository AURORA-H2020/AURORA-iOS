import Foundation

// MARK: - RecurringConsumption+Frequency+Weekday

extension RecurringConsumption.Frequency {
    
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

// MARK: - Weekday+Comparable

extension RecurringConsumption.Frequency.Weekday: Comparable {
    
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than that of the second argument.
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func < (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
}

// MARK: - Weekday+localizedString

extension RecurringConsumption.Frequency.Weekday {
    
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
