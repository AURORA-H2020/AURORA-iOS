import Foundation

// MARK: - ConsumptionSummary+LabeledConsumption

extension ConsumptionSummary {
    
    /// A consumption summary labeled consumption.
    struct LabeledConsumption: Codable, Hashable, Sendable {
        
        /// The total value.
        let total: Double
        
        /// The percentage value.
        let percentage: Double?
        
        /// The label.
        let label: Label?
        
    }
    
}
