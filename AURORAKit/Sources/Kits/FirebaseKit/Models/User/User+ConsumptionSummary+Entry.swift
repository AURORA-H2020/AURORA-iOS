import Foundation

// MARK: - User+ConsumptionSummary+Entry

public extension User.ConsumptionSummary {
    
    /// A consumption summary entry
    struct Entry: Codable, Hashable, Sendable {
        
        // MARK: Properties
        
        /// The consumption category.
        public let category: Consumption.Category
        
        /// The value.
        public let value: Double
        
        // MARK: Initializer
        
        /// Creates a new instance of `User.ConsumptionSummary.Entry`
        /// - Parameters:
        ///   - category: The consumption category.
        ///   - value: The value.
        public init(
            category: Consumption.Category,
            value: Double
        ) {
            self.category = category
            self.value = value
        }
        
    }
    
}

// MARK: - Identifiable

extension User.ConsumptionSummary.Entry: Identifiable {
    
    /// The stable identity of the entity associated with this instance.
    public var id: Consumption.Category {
        self.category
    }
    
}
