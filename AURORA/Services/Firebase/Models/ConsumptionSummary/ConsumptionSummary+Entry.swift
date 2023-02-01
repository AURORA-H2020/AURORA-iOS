import Foundation

// MARK: - ConsumptionSummary+Entry

extension ConsumptionSummary {
    
    /// A consumption summary entry
    struct Entry: Codable, Hashable, Sendable {
        
        // MARK: Properties
        
        /// The consumption category.
        let category: Consumption.Category
        
        /// The value.
        let value: Double
        
        // MARK: Initializer
        
        /// Creates a new instance of `ConsumptionSummary.Entry`
        /// - Parameters:
        ///   - category: The consumption category.
        ///   - value: The value.
        init(
            category: Consumption.Category,
            value: Double
        ) {
            self.category = category
            self.value = value
        }
        
    }
    
}

// MARK: - Identifiable

extension ConsumptionSummary.Entry: Identifiable {
    
    /// The stable identity of the entity associated with this instance.
    var id: Consumption.Category {
        self.category
    }
    
}
