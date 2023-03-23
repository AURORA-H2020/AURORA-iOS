import Foundation

// MARK: - ConsumptionSummary+Category

extension ConsumptionSummary {
    
    /// A category object of a consumption summary
    struct Category: Codable, Hashable, Sendable {
        
        /// The consumption category
        let category: Consumption.Category
        
        /// The carbon emission labled consumption.
        let carbonEmission: ConsumptionSummary.LabeledConsumption
        
        /// The enerfy expended labled consumption.
        let energyExpended: ConsumptionSummary.LabeledConsumption
        
    }
    
}

// MARK: - ConsumptionSummary+Category+Identifiable

extension ConsumptionSummary.Category: Identifiable {
    
    /// The stable identity of the entity associated with this instance.
    var id: Consumption.Category {
        self.category
    }
    
}
