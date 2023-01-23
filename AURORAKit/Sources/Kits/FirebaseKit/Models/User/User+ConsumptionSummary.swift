import Foundation

// MARK: - User+ConsumptionSummary

public extension User {
    
    /// A consumption summary
    struct ConsumptionSummary: Codable, Hashable, Sendable {
        
        // MARK: Properties
        
        /// The total carbon emissions.
        public let totalCarbonEmissions: Decimal
        
        /// The entries
        public let entries: [Entry]
        
        // MARK: Initializer
        
        /// Creates a new instance of `User.ConsumptionSummary`
        /// - Parameters:
        ///   - totalCarbonEmissions: The total carbon emissions.
        ///   - entries: The entries.
        public init(
            totalCarbonEmissions: Decimal,
            entries: [Entry]
        ) {
            self.totalCarbonEmissions = totalCarbonEmissions
            self.entries = entries
        }
        
    }
    
}
