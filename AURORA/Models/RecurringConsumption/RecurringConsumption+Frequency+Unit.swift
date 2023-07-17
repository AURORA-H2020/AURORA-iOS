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
