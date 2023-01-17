import Foundation

// MARK: - Consumption+Category

public extension Consumption {
    
    /// A Consumption Category
    enum Category: String, Codable, Hashable, CaseIterable, Sendable {
        /// Transportation
        case transportation
        /// Heating
        case heating
        /// Electricity
        case electricity
    }
    
}
