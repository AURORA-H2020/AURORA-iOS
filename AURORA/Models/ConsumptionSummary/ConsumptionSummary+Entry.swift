import Foundation

// MARK: - ConsumptionSummary+Entry

extension ConsumptionSummary {
    
    /// A consumption summary entry
    struct Entry: Codable, Hashable, Sendable {
        
        /// The consumption category.
        let category: Consumption.Category
        
        /// The value.
        let value: Double
        
    }
    
}

// MARK: - Identifiable

extension ConsumptionSummary.Entry: Identifiable {
    
    /// The stable identity of the entity associated with this instance.
    var id: Consumption.Category {
        self.category
    }
    
}
