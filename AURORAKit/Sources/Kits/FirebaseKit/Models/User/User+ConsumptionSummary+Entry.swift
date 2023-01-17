import Foundation

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

// MARK: - Identifiable

extension User.ConsumptionSummary.Entry: Identifiable {
    
    /// The stable identity of the entity associated with this instance.
    public var id: String {
        self.category
    }
    
}
