import Foundation

// MARK: - User+ConsumptionSummary

public extension User {
    
    /// A consumption summary
    struct ConsumptionSummary: Codable, Hashable {
        
        // MARK: Properties
        
        /// The total carbon emissions.
        public let totalCarbonEmissions: Double
        
        /// The entries
        public let entries: [Entry]
        
        // MARK: Initializer
        
        /// Creates a new instance of `User.ConsumptionSummary`
        /// - Parameters:
        ///   - totalCarbonEmissions: The total carbon emissions.
        ///   - entries: The entries.
        public init(
            totalCarbonEmissions: Double,
            entries: [Entry]
        ) {
            self.totalCarbonEmissions = totalCarbonEmissions
            self.entries = entries
        }
        
    }
    
}

// MARK: - User+ConsumptionSummary+Entry

public extension User.ConsumptionSummary {
    
    /// A consumption summary entry
    struct Entry: Codable, Hashable {
        
        // MARK: Properties
        
        /// The category.
        public let category: String
        
        /// The value.
        public let value: Double
        
        // MARK: Initializer
        
        /// Creates a new instance of `User.ConsumptionSummary.Entry`
        /// - Parameters:
        ///   - category: The category.
        ///   - value: The value.
        public init(
            category: String,
            value: Double
        ) {
            self.category = category
            self.value = value
        }
        
    }
    
}
