import Foundation

// MARK: - Consumption+Category

public extension Consumption {
    
    /// A Consumption Category
    enum Category: String, Codable, Hashable, CaseIterable, Sendable {
        /// Electricity
        case electricity
        /// Heating
        case heating
        /// Transportation
        case transportation
    }
    
}
